//
//  Content2ViewModel.swift
//  btest
//
//  Created by ukseung.dev on 1/31/25.
//

import Combine
import Alamofire
import Foundation

// args 구조체
struct Args: Codable {
    let query: String
}

// headers 구조체
struct Headers: Codable {
    let host: String?
    let xRequestStart: String?
    let connection: String?
    let xForwardedProto: String?
    let xForwardedPort: String?
    let xAmznTraceId: String?
    let userAgent: String?
    let accept: String?
    let cacheControl: String?  // Optional로 수정
    let postmanToken: String?
    let acceptEncoding: String?
    let cookie: String?
    
    // JSON 키 매핑 (snake_case -> camelCase)
    enum CodingKeys: String, CodingKey {
        case host
        case xRequestStart = "x-request-start"
        case connection
        case xForwardedProto = "x-forwarded-proto"
        case xForwardedPort = "x-forwarded-port"
        case xAmznTraceId = "x-amzn-trace-id"
        case accept
        case userAgent = "user-agent"
        case cacheControl = "cache-control"
        case postmanToken = "postman-token"
        case acceptEncoding = "accept-encoding"
        case cookie
    }
}

// 전체 응답 구조체
struct APIResponse: Codable {
    let args: Args
    let headers: Headers?  // Optional로 처리
    let url: String
}


final class Content2ViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: APIResponse?
    
    private var cancellables: Set<AnyCancellable> = []
    private var currentRequest: AnyCancellable? // 기존 요청을 취소할 수 있는 변수

    init() {
        $query
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.searchAPI(query: query) // 쿼리값을 받으면 searchAPI 호출
            }
            .store(in: &cancellables)
    }
    
    // API 호출 함수
    private func searchAPI(query: String) {
        // 이전 요청을 취소
        currentRequest?.cancel()
        
        // 새로운 요청을 보내는 코드
        currentRequest = URLSession.shared.dataTaskPublisher(for: createURL(query: query))
            .map { data, _ in
                do {
                    // 응답을 디코딩하여 반환
                    let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    return decodedResponse
                } catch {
                    print("🔥 디코딩 에러: \(error.localizedDescription)")
                    return APIResponse(args: Args(query: ""), headers: nil, url: "")
                }
            }
            .mapError { error in
                error
            }
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] result in
                self?.results = result
            })
        
        // 요청을 실행
        currentRequest?.store(in: &cancellables)
    }

    private func createURL(query: String) -> URL {
        guard var urlComponents = URLComponents(string: "https://postman-echo.com/get") else {
            return URL(string: "")!
        }
        urlComponents.queryItems = [URLQueryItem(name: "query", value: query)]
        return urlComponents.url!
    }
}

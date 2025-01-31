//
//  NetworkManager.swift
//  btest
//
//  Created by ukseung.dev on 1/31/25.
//


import Alamofire
import Foundation

class NetworkManager {
    private var session: Session
    private var accessToken: String
    private var refreshToken: String

    init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        
        // `TokenInterceptor`를 사용하여 `Session` 설정
        let interceptor = TokenInterceptor(accessToken: accessToken, refreshToken: refreshToken)
        self.session = Session(interceptor: interceptor)
    }

    // API 요청 함수 예시
    func fetchData(from url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        session.request(url)
            .validate(statusCode: 200..<300)  // 2xx 범위 내 응답만 처리
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

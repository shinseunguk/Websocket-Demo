//
//  TokenInterceptor.swift
//  btest
//
//  Created by ukseung.dev on 1/31/25.
//

import Alamofire
import Foundation

class TokenInterceptor: RequestInterceptor {
    private var refreshToken: String
    private var accessToken: String

    init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    // 요청 전 인터셉터로 AccessToken을 헤더에 추가
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    // 응답 처리: 401 에러 발생 시 AccessToken 갱신
    func retry(_ request: Request, for session: Session, dueTo error: AFError, with completion: @escaping (RetryResult) -> Void) {
        if error.isResponseValidationError && request.response?.statusCode == 401 {
            // 토큰이 만료된 경우, refreshToken을 사용해 새로운 accessToken 발급 받기
            refreshAccessToken { [weak self] newAccessToken in
                if let newAccessToken = newAccessToken {
                    // 새로운 토큰을 갱신 후, 원래 요청을 재시도
                    self?.accessToken = newAccessToken
                    completion(.retry)
                } else {
                    // 새로운 토큰 발급 실패 시 재시도하지 않음
                    completion(.doNotRetry)
                }
            }
        } else {
            // 다른 에러는 재시도하지 않음
            completion(.doNotRetry)
        }
    }

    // refreshToken을 사용하여 새로운 accessToken을 발급받는 함수
    private func refreshAccessToken(completion: @escaping (String?) -> Void) {
        // API를 호출하여 새로운 accessToken을 발급받습니다.
        let parameters: [String: Any] = ["refresh_token": refreshToken]
        
        // 여기서 refreshToken을 사용하여 새로운 accessToken을 요청합니다.
        AF.request("https://yourapi.com/refresh", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    // 서버에서 반환한 새 accessToken 추출 (예시)
                    if let data = json as? [String: Any], let newAccessToken = data["access_token"] as? String {
                        completion(newAccessToken)
                    } else {
                        completion(nil)
                    }
                case .failure:
                    completion(nil)
                }
            }
    }
}

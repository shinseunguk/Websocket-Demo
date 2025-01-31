//
//  ContentViewModel.swift
//  btest
//
//  Created by ukseung.dev on 1/31/25.
//  wss://ws.postman-echo.com/raw

import Foundation
import Combine
import Starscream

final class ContentViewModel: ObservableObject {
    public var result = PassthroughSubject<[String], Never>()
    var resultArray: [String] = []
    
    @Published public var publishedResultArray: [String] = []
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var isConnected: Bool = false
    var socket: WebSocket?
    
    init() {
        result
            .sink { [weak self] messages in
                self?.publishedResultArray = messages
            }
            .store(in: &cancellables)
    }
    
    func connect() {
        var request = URLRequest(url: URL(string: "wss://ws.postman-echo.com/raw")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    func disconnect() {
        socket?.disconnect()
    }
    
    func sendMessage(_ message: String) {
        socket?.write(string: message)
    }
}

extension ContentViewModel: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            
            if resultArray.count > 100 {
                resultArray.removeFirst()
            }
            
            resultArray.append(string)
            
            result.send(resultArray)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
//            handleError(error)
            case .peerClosed:
                   break
        }
    }
}

//
//  DictionaryEncodableProtocol.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/12.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import Foundation

protocol DictionaryEncodable: Encodable {}

extension DictionaryEncodable {
    func dictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        guard let json = try? encoder.encode(self),
            let dict = try? JSONSerialization.jsonObject(with: json, options: []) as? [String: Any] else {
                return nil
        }
        return dict
    }
}

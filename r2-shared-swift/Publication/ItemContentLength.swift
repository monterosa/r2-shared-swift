//
//  ItemContentLength.swift
//  r2-shared-swift
//
//  Created by Vasyl Fedasiuk on 17.02.2020.
//
//  Copyright 2020 Readium Foundation. All rights reserved.
//  Use of this source code is governed by a BSD-style license which is detailed
//  in the LICENSE file present in the project repository where this source code is maintained.
//

import Foundation

public struct ItemContentLength {
    public let item: Link
    public let contentLength: Int
    public let percentOfTotal: Double
}

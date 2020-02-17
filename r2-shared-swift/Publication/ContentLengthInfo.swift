//
//  ContentLengthInfo.swift
//  r2-shared-swift
//
//  Created by Vasyl Fedasiuk on 17.02.2020.
//
//  Copyright 2020 Readium Foundation. All rights reserved.
//  Use of this source code is governed by a BSD-style license which is detailed
//  in the LICENSE file present in the project repository where this source code is maintained.
//

import Foundation

public class ContentLengthInfo {
    
    public struct PageProgress: Equatable {
        public let documentProgress: Double
        public let totalProgress: Double
    }
    
    public struct PublicationPosition {
        public let documentIndex: Int
        public let progressInDocument: Double
    }
    
    enum ContentError: Error {
        case invalidPages
        case noSpineContentLengthInfo
    }
    
    public init(contentLengthTuples: [(spineLink: Link, contentLength: Int)]) {
        let totalLength = contentLengthTuples.reduce(0, {$0 + $1.contentLength})
        self.totalLength = totalLength
        
        guard totalLength > 0 else {
            itemContentLengths = []
            return
        }
        
        itemContentLengths = contentLengthTuples.map({ (tuple) -> ItemContentLength in
            let percent = Double(tuple.contentLength) / Double(totalLength)
            return ItemContentLength(item: tuple.spineLink, contentLength: tuple.contentLength, percentOfTotal: percent)
        })
        
        assert(
            contentLengthTuples.count == 0 ||
                itemContentLengths.reduce(0, {$0 + $1.percentOfTotal}) >= 0.99999999999
        )
    }
    
    public let itemContentLengths: [ItemContentLength]
    
    public var totalLength: Int
}

public extension ContentLengthInfo {
    
    func pageProgressFor(currentDocumentIndex: Int, progressInDocument: Double) throws -> PageProgress {
        return try pageProgressFor(currentDocumentIndex: currentDocumentIndex,
                               documentProgress: progressInDocument)
    }
    
    private func pageProgressFor(currentDocumentIndex: Int, documentProgress: Double) throws -> PageProgress {
        guard itemContentLengths.count > currentDocumentIndex else { throw ContentError.noSpineContentLengthInfo }
        
        var startOfDocumentTotalProgress: Double = 0
        for (index, element) in itemContentLengths.enumerated() {
            if index >= currentDocumentIndex { break }
            startOfDocumentTotalProgress += element.percentOfTotal
        }
        
        let documentLengthPercentOfTotal = itemContentLengths[currentDocumentIndex].percentOfTotal
        
        let pageStartPercentOfTotal = documentLengthPercentOfTotal * documentProgress
        let pageStartTotalProgress = startOfDocumentTotalProgress + pageStartPercentOfTotal
        
        let pageEndPercentOfTotal = documentLengthPercentOfTotal * documentProgress
        let pageEndTotalProgress = min(startOfDocumentTotalProgress + pageEndPercentOfTotal, 1)
        
        assert(pageEndTotalProgress >= 0 && pageEndTotalProgress <= 1.0)
        assert(pageStartTotalProgress >= 0 && pageStartTotalProgress <= pageEndTotalProgress)
        
        return PageProgress(documentProgress: documentProgress,
                            totalProgress: pageStartTotalProgress)
    }
    
    func positionFor(totalStartProgress: Double) throws -> PublicationPosition {
        guard itemContentLengths.count > 0 else { throw ContentError.noSpineContentLengthInfo }
        guard var theSpineInfo = itemContentLengths.first else { throw ContentError.noSpineContentLengthInfo }
        var documentIndex = 0
        var startOfDocumentTotalProgress: Double = 0
        
        while totalStartProgress >= startOfDocumentTotalProgress + theSpineInfo.percentOfTotal {
            let previousSpineInfo = theSpineInfo
            
            if documentIndex == itemContentLengths.count-1 { break }
            
            documentIndex += 1
            theSpineInfo = itemContentLengths[documentIndex]
            startOfDocumentTotalProgress += previousSpineInfo.percentOfTotal
        }

        assert(totalStartProgress < startOfDocumentTotalProgress + theSpineInfo.percentOfTotal + 0.000000000000001)
        assert(totalStartProgress >= startOfDocumentTotalProgress)
        
        let totalPercentIntoDocument = (totalStartProgress - startOfDocumentTotalProgress)
        let progressInDocument = min(totalPercentIntoDocument / theSpineInfo.percentOfTotal, 1)
        
        return PublicationPosition(documentIndex: documentIndex, progressInDocument: progressInDocument)
    }
}

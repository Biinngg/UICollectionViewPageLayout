//
//  UICollectionViewPageLayout.swift
//  UICollectionViewPageLayout
//
//  Created by Liu Bing on 9/25/15.
//  Copyright © 2015 UnixOSS. All rights reserved.
//

import UIKit

public class UICollectionViewPageLayout: UICollectionViewLayout {
    
    public var itemSize: CGSize = CGSizeZero
    
    private var layoutInformation = [NSIndexPath: UICollectionViewLayoutAttributes]()
    private var pageCount = 0
    
    public override func prepareLayout() {
        if itemSize.width == 0 || itemSize.height == 0 || collectionView == nil {
            return
        }
        let rowsPerPage = Int(collectionView!.bounds.size.height / itemSize.height)
        let columnsPerPage = Int(collectionView!.bounds.size.width / itemSize.width)
        let countsPerPage = rowsPerPage * columnsPerPage
        
        collectionView?.pagingEnabled = true
        var _layoutInformation = [NSIndexPath: UICollectionViewLayoutAttributes]()
        var index = 0
        let sectionCount = collectionView?.numberOfSections() ?? 0
        for section in 0..<sectionCount {
            let itemCount = collectionView?.numberOfItemsInSection(section) ?? 0
            for item in 0..<itemCount {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                let page = index / countsPerPage
                let count = index % countsPerPage
                let row = count / columnsPerPage
                let column = count % columnsPerPage
                _layoutInformation[indexPath] = attributesAtIndexPath(indexPath, page: page, row: row, column: column)
                index++
            }
        }
        layoutInformation = _layoutInformation
        pageCount = (index % countsPerPage != 0) ? index / countsPerPage + 1 : index / countsPerPage
    }
    
    private func attributesAtIndexPath(indexPath: NSIndexPath, page: Int, row: Int, column: Int) -> UICollectionViewLayoutAttributes {
        let originX = CGFloat(page) * (collectionView?.bounds.size.width ?? 0) + CGFloat(column) * itemSize.width
        let originY = itemSize.height * CGFloat(row)
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.frame = CGRect(x: originX, y: originY, width: itemSize.width, height: itemSize.height)
        return attributes
    }
    
    public override func collectionViewContentSize() -> CGSize {
        let collectionViewSize = collectionView?.bounds.size ?? CGSizeZero
        return CGSize(width: collectionViewSize.width * CGFloat(pageCount), height: collectionViewSize.height)
    }
    
    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        for (_, value) in layoutInformation {
            if CGRectIntersectsRect(rect, value.frame) {
                attributes.append(value)
            }
        }
        return attributes
    }
    
    public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutInformation[indexPath]
    }
    
}

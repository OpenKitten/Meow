import Foundation

extension Model {
    /// A pagination result
    public typealias PaginatedFindResult = (total: Int, perPage: Int, currentPage: Int, lastPage: Int, from: Int, to: Int, data: CollectionSlice<Self>)
    
    /// Performs a find on the model, with support for pagination.
    ///
    /// - parameter query: The find query
    /// - parameter sort: Standard MongoKitten sort parameter
    /// - parameter page: The page number, starting at 1 (thus, specifying a page of 0 is invalid and will throw an error)
    /// - parameter perPage: The amount of results to include on a page, defaulting to 25
    public static func paginatedFind(_ query: MongoKitten.Query? = nil, sortedBy sort: Sort? = nil, page: Int, perPage: Int = 25) throws -> PaginatedFindResult {
        let totalCount = try Self.count(query)
        let skip = (page-1) * perPage
        let data = try Self.find(query, sortedBy: sort, skipping: skip, limitedTo: perPage, withBatchSize: perPage)
        
        var lastPage = totalCount / perPage
        if totalCount % perPage > 0 {
            lastPage += 1
        }
        
        var to = skip + perPage
        if to > totalCount {
            to = totalCount
        }
        
        return (
            total: totalCount,
            perPage: perPage,
            currentPage: page,
            lastPage: lastPage,
            from: skip+1,
            to: to,
            data: data
        )
    }
}

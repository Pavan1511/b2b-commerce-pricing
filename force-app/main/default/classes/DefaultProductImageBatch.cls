global class DefaultProductImageBatch implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id
            FROM Product2
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Product2> scope) {

        // Collect Product Ids from this batch chunk
        Set<Id> productIds = new Set<Id>();
        for (Product2 p : scope) {
            productIds.add(p.Id);
        }

        // Find which of these already have media
        Set<Id> productIdsWithMedia = new Set<Id>();

        for (ProductMedia pm : [
            SELECT ProductId
            FROM ProductMedia
            WHERE ProductId IN :productIds
        ]) {
            productIdsWithMedia.add(pm.ProductId);
        }

        // Prepare ProductMedia records for products without media
        List<ProductMedia> mediaToInsert = new List<ProductMedia>();

        for (Product2 p : scope) {
            if (!productIdsWithMedia.contains(p.Id)) {

                ProductMedia pm = new ProductMedia();
                pm.ProductId = p.Id;
                pm.ElectronicMediaId = System.Label.Default_Product_ElectronicMediaId;
                pm.ElectronicMediaGroupId = System.Label.Default_Product_ElectronicMediaGroupId;
                pm.SortOrder = 1;

                mediaToInsert.add(pm);
            }
        }

        if (!mediaToInsert.isEmpty()) {
            insert mediaToInsert;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Default image batch completed.');
    }
}
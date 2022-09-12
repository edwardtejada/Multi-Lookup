public with sharing class LookupController {
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';

        List<List<SObject>> searchResults = [
            FIND :searchTerm IN ALL FIELDS RETURNING
            Account (Id, Name, BillingCity WHERE Id NOT IN :selectedIds),
            Opportunity (Id, Name, StageName WHERE Id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS
        ];

        List<LookupSearchResult> results = new List<LookupSearchResult>();

        String accountIcon = 'standard:account';
        Account [] accounts = ((List<Account>) searchResults[0]);
        for (Account account : accounts) {
            LookupSearchResult lookupSearchResult = new LookupSearchResult();
            lookupSearchResult.id = account.Id;
            lookupSearchResult.getSObjectType = 'Account';
            lookupSearchResult.icon = accountIcon;
            lookupSearchResult.title = account.Name;
            lookupSearchResult.subtitle = 'Account • '+ account.BillingCity;

            results.add(lookupSearchResult);
        }

        String opptyIcon = 'standard:opportunity';
        Opportunity [] opptys = ((List<Opportunity>) searchResults[1]);
        for (Opportunity oppty : opptys) {
            LookupSearchResult lookupSearchResult = new LookupSearchResult();
            lookupSearchResult.id = oppty.Id;
            lookupSearchResult.getSObjectType = 'Opportunity';
            lookupSearchResult.icon = opptyIcon;
            lookupSearchResult.title = oppty.Name;
            lookupSearchResult.subtitle = 'Opportunity • '+ oppty.StageName;

            results.add(lookupSearchResult);
        }

        return results;
    }

    public class LookupSearchResult {
        @AuraEnabled
        public Id id {get; set;}

        @AuraEnabled
        public String getSObjectType {get; set;}

        @AuraEnabled
        public String icon {get; set;}

        @AuraEnabled
        public String title {get; set;}

        @AuraEnabled
        public String subtitle {get; set;}
    }
}

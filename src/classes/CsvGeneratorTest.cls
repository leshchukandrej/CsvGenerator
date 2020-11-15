@IsTest
public with sharing class CsvGeneratorTest {

    static final Map<String, String> RECORD_PATHS = new Map<String, String>{
            'FirstName' => 'FirstName',
            'Account.Name' => 'Account Name'
    };

    static final List<String> OBJECT_PATHS = new List<String>{
            'level1Field', 'level2Object.level2Field'
    };

    @IsTest static void genCsvFromObjects() {
        List<Object> records = new List<Object>{
                gen1LevelObjectRow('obj1'),
                gen2LevelObjectRow('obj1', null),
                gen2LevelObjectRow('obj1', 'obj2')
        };

        CsvGenerator csvGeneratorInst = new CsvGenerator()
                .setName('CsvFromObjects')
                .setColumns(OBJECT_PATHS)
                .setRecords(records);

        String data = csvGeneratorInst.generateCsv().data;

        List<String> expectedRows = new List<String>{
                toRow(OBJECT_PATHS),
                toRow(new List<String>{'obj1', null}),
                toRow(new List<String>{'obj1', null}),
                toRow(new List<String>{'obj1', 'obj2'})
        };

        System.assertEquals(csvGeneratorInst.getColumnApiNames(), OBJECT_PATHS);
        System.assertEquals(String.join(expectedRows, CsvGenerator.ROW_DELIMITER), data);
    }

    @IsTest static void genCsvFromSObjects() {
        List<Contact> contacts = new List<Contact>{
                new Contact(FirstName = 'Contact1'),
                new Contact(FirstName = 'Contact2', Account = new Account()),
                new Contact(FirstName = 'Contact3', Account = new Account(Name = 'Account1')),
                new Contact(FirstName = 'Contact4', Account = new Account(Name = 'Account2'))
        };

        CsvGenerator csvGeneratorInst = new CsvGenerator()
                .setName('CsvFromSObjects')
                .setColumns(RECORD_PATHS)
                .setRecords(contacts);

        String data = csvGeneratorInst.generateCsv().data;

        List<String> expectedRows = new List<String>{
                toRow(RECORD_PATHS.values()),
                toRow(new List<String>{'Contact1', null}),
                toRow(new List<String>{'Contact2', null}),
                toRow(new List<String>{'Contact3', 'Account1'}),
                toRow(new List<String>{'Contact4', 'Account2'})
        };

        System.assertEquals(csvGeneratorInst.getColumnApiNames(), new List<String>(RECORD_PATHS.keySet()));
        System.assertEquals(String.join(expectedRows, CsvGenerator.ROW_DELIMITER), data);
    }

    @IsTest static void setColumnsFromSObjectFields() {
        List<SObjectField> sObjectFields = new List<SObjectField>{
                Contact.FirstName,
                Contact.LastName
        };

        List<String> fieldApiNames = new CsvGenerator().setColumns(sObjectFields).getColumnApiNames();

        List<String> expectedApiNames = new List<String>();

        for (SObjectField sObjectField: sObjectFields) {
            expectedApiNames.add(sObjectField.getDescribe().getName());
        }

        System.assertEquals(expectedApiNames, fieldApiNames);
    }

    static Object gen1LevelObjectRow(String level1Field) {
        return convertToObject(new Level1Object(level1Field, null));
    }

    static Object gen2LevelObjectRow(String level1Field, String level2Field) {
        return convertToObject(new Level1Object(level1Field, new Level2Object(level2Field)));
    }

    static Object convertToObject(Object obj) {
        return JSON.deserializeUntyped(JSON.serialize(obj));
    }

    static String toRow(List<String> data) {
        List<String> dataWithoutNulls = new List<String>();
        for (String column : data) {
            dataWithoutNulls.add(String.isNotEmpty(column) ? column : '');
        }
        return String.join(dataWithoutNulls, CsvGenerator.COLUMN_DELIMITER);
    }

    class Level1Object {
        String level1Field;
        Level2Object level2Object;

        public Level1Object(String level1Field, Level2Object level2Object) {
            this.level1Field = level1Field;
            this.level2Object = level2Object;
        }
    }

    class Level2Object {
        String level2Field;

        public Level2Object(String level2Field) {
            this.level2Field = level2Field;
        }
    }

}
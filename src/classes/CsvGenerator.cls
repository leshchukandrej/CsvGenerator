public with sharing class CsvGenerator {

    @TestVisible
    private static final String COLUMN_DELIMITER = ',';
    @TestVisible
    private static final String ROW_DELIMITER = '\n';
    @TestVisible
    private static final String FIELD_PATH_DELIMITER = '\\.';

    private String fileName { get; set; }
    private Map<String, String> columns;
    private List<Object> records;

    public CsvGenerator setName(String fileName) {
        this.fileName = fileName;
        return this;
    }

    public CsvGenerator setColumns(Schema.FieldSet fieldset) {
        Map<String, String> columns = new Map<String, String>();
        for (FieldSetMember fieldSetMember: fieldset.getFields()) {
            columns.put(fieldSetMember.fieldPath, fieldSetMember.label);
        }
        return this.setColumns(columns);
    }

    public CsvGenerator setColumns(List<SObjectField> SObjectFields) {
        Map<String, String> columns = new Map<String, String>();
        for (SObjectField sObjectField: SObjectFields) {
            columns.put(sObjectField.getDescribe().getName(), sObjectField.getDescribe().getLabel());
        }
        return this.setColumns(columns);
    }

    public CsvGenerator setColumns(List<String> fieldApiNames) {
        Map<String, String> columns = new Map<String, String>();
        for (String fieldApiName: fieldApiNames) {
            columns.put(fieldApiName, fieldApiName);
        }
        System.debug( columns );
        return this.setColumns(columns);
    }

    public CsvGenerator setColumns(Map<String, String> columns) {
        this.columns = columns;
        return this;
    }

    public CsvGenerator setRecords(List<Object> records) {
        this.records = records;
        return this;
    }

    public List<String> getColumnApiNames() {
        return new List<String>(this.columns.keySet());
    }

    public CsvContainer generateCsv() {
        List<String> rows = new List<String>();
        //add csv header
        rows.add(this.getHeader());

        //add csv row values
        for (Object record : this.records) {
            rows.add(this.getRow(record));
        }

        CsvContainer csvContainer = new CsvContainer();
        csvContainer.fileName = this.fileName;
        csvContainer.data = String.join(rows, ROW_DELIMITER);

        return csvContainer;
    }

    private String getHeader() {
        return String.join(this.columns.values(), COLUMN_DELIMITER);
    }

    private String getRow(Object record) {
        List<String> columns = new List<String>();
        for (String fieldPath : this.columns.keySet()) {
            String column = String.valueOf(this.getValueFromObjectByPath(record, fieldPath.split(FIELD_PATH_DELIMITER)));
            columns.add(String.isNotEmpty(column) ? column : '');
        }
        return String.join(columns, COLUMN_DELIMITER);
    }

    private Object getValueFromObjectByPath(Object obj, List<String> path) {
        if (obj instanceof SObject) {
            return this.getValueByFieldPath((SObject) obj, path);
        }

        try {
            if (path.size() == 0) {
                return obj;
            }

            Map<String, Object> valueByKey = (Map<String, Object>) obj;
            if (path.size() > 1) {
                return this.getValueFromObjectByPath(valueByKey.get(path.remove(0)), path);
            }
            return valueByKey.get(path.remove(0));
        } catch (Exception e) {
            System.debug('\n\n e.getMessage() => ' + e.getMessage() + '\n');
            return null;
        }
    }

    private Object getValueByFieldPath(SObject record, List<String> fieldPath) {
        if (record == null || fieldPath.size() == 0) return null;

        try {
            if (fieldPath.size() > 1) {
                return this.getValueByFieldPath(record.getSObject(fieldPath.remove(0)), fieldPath);
            }
            return record.get(fieldPath.remove(0));
        } catch (Exception e) {
            System.debug('\n\n e.getMessage() => ' + e.getMessage() + '\n');
            return null;
        }
    }

    public class CsvContainer {
        public String fileName { get; set; }
        public String data { get; set; }
    }
}
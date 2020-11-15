# CsvGenerator

This class is used for generating CsvContainer that contains data with constructure same as csv.

For column mapping you can use FieldSet, List<SObjectField>, List<String> or even Map<String, String>.

It can take as List<SObject> as List<Object> in case objects were serialized and then deserialized to Object.

Samples of using CsvGenerator is in test class CsvGeneratorTest.

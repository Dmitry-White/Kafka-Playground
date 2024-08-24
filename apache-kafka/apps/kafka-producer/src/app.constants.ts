const EXAMPLE_SCHEMA = `
    {
    "type": "record",
    "name": "Example",
    "namespace": "examples",
    "fields": [{ "type": "string", "name": "test" }]
    }
`;

const KAFKA_SASL_MECHANISM = 'plain';

export {
    EXAMPLE_SCHEMA,
    KAFKA_SASL_MECHANISM
}
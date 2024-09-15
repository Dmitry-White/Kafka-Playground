# @dmitrywhite/kafka/client

This is a NestJS module that integrates with [KafkaJS](https://kafka.js.org/) and [KafkaJS Schema Registry](https://kafkajs.github.io/confluent-schema-registry/).
It provides a client that prepares Kafka Broker and Schema Registry for further usage.

## Usage

Import it either directly to `AppModule` root module or an intermediary `LocalKafkaClientModule` lib module in the following way:

```javascript
imports: [
	...
	KafkaClientModule.forRootAsync(MODULE_CONFIGURATION),
	...
];
```

This would enable your consuming app to have Kafka Broker and Schema Registry instances ready for usage in Kafka Producers and/or Consumers.
Depending on configuration passed to the module (`MODULE_CONFIGURATION` object above), some client settings in this module will have different behaviour.

## Configuration

To configure this Kafka Client module, the following fields in `MODULE_CONFIGURATION` object need to be filled in:

- `imports` - list of required and optional modules from a consuming app;
- `inject` - list of services the consuming app wants to provide to the module;
- `useFactory` - concrete implementation of how services from `inject` field are used to construct dynamic options;

`useFactory` function returns an `options` [object for internal dynamic provider](https://docs.nestjs.com/fundamentals/dynamic-modules#custom-options-factory-class), corresponds to `KafkaClientOptions` type in `client.types.ts`:

- `clientId` corresponds to consuming application label with Kafka;
- `brokerUri` corresponds to Kafka Broker URI (either local or Aiven) that the consuming app wants to connect to and should be valid for TCP connection;
- `schemaRegistryUri` corresponds to Kafka Schema Registry URI (either local or Aiven) that the consuming app wants to connect to and should be valid for HTTP connection;
- `username` & `password` correspond to Kafka User credentials (either local or Aiven) that the consuming app would use to authenticate against Kafka Broker & Schema Registry. Authentication process uses SASL protocol with the mechanism defined in `KAFKA_SASL_MECHANISM` constant. Authorisation settings are configured inside the target Kafka cluster itself (either local or Aiven).
- `schemas` corresponds to a list of schemas this Kafka Client needs to make sure are registered in Kafka Schema Registry for further usage/reference by Kafka Provider and/or Consumer;

### Configuration Example

`MODULE_CONFIGURATION` object:

```javascript
{
	imports: [ConfigModule],
    inject: [ConfigService],
    useFactory: (configService: ConfigService) => ({
        clientId: configService.get('KAFKA_CLIENT_ID'),
        brokerUri: configService.get('KAFKA_BROKER_URI'),
        schemaRegistryUri: configService.get('KAFKA_SCHEMA_REGISTRY_URI'),
        username: configService.get('KAFKA_USERNAME'),
        password: configService.get('KAFKA_PASSWORD'),
        schemas: [/*some schemas of type ParsedSchema*/],
        topics: [/*some topic object of type ParsedTopic*/],
    }),
}
```

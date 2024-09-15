# @dmitrywhite/kafka/consumer

This is a NestJS module that integrates with [KafkaJS](https://kafka.js.org/) and [KafkaJS Schema Registry](https://kafkajs.github.io/confluent-schema-registry/).
It provides a Kafka consumer that listens to the messages on the specified topic and runs a provided handler for each received message via an already initialised Kafka Client in the consuming app.

## Usage

The consuming app is **required** to have a `KafkaClientModule` **already initialised**.
Import this consumer module either directly to `AppModule` root module or an intermediary `LocalKafkaConsumerModule` lib module in the following way:

```javascript
imports: [
	...
	KafkaConsumerModule.forRootAsync(MODULE_CONFIGURATION),
	...
];
```

This would enable your consuming app to have Kafka Basic Consumer configured and listening to the provided topic messages, reacting to them automatically with the specified handler without any further manual intervention.
Depending on configuration passed to the module (`MODULE_CONFIGURATION` object above), some consumer settings in this module will have different behaviour.

## Configuration

To configure this Kafka Basic Consumer module, the following fields in `MODULE_CONFIGURATION` object need to be filled in:

- `imports` - list of required and optional modules from a consuming app;
- `inject` - list of services the consuming app wants to provide to the module;
- `useFactory` - concrete implementation of how services from `inject` field are used to construct dynamic options;

`useFactory` function returns an `options` [object for internal dynamic provider](https://docs.nestjs.com/fundamentals/dynamic-modules#custom-options-factory-class), corresponds to `KafkaConsumerOptions` type in `consumer.types.ts`:

- `topic` corresponds to Kafka topic the consuming application wants to listen to;
- `groupId` corresponds to a Kafka Consumer Group the consuming application wants to be part of, which affects how/when messages are processed in the case of several consumers subscribed to the same topic;
- `handler` corresponds to a function that acts like a callback to event of consumer receiving a message from the specified topic;

### Configuration Example

`MODULE_CONFIGURATION` object:

```javascript
{
      imports: [
        LoggerModule.forFeature('Local Kafka Basic Consumer'),
        ConfigModule,
      ],
      inject: [ConfigService, LoggerService],
      useFactory: (configService: ConfigService, logger: LoggerService) => ({
        topic: {/*some topic object of type ParsedTopic*/},
        groupId: configService.get('KAFKA_GROUP'),
        handler: async ({ topic, partition, message }: EachMessagePayload) => {
          logger.debug(
            `Topic "${topic}:${partition}" received message: ${message.value?.toString()}`,
          );
        },
      }),
    }
```

# @dmitrywhite/kafka/producer

This is a NestJS module that integrates with [KafkaJS](https://kafka.js.org/) and [KafkaJS Schema Registry](https://kafkajs.github.io/confluent-schema-registry/).
It provides a Kafka producer that provides a service with ability to send messages to the any topic passed to its method(s) via an already initialised Kafak Client in the consuming app.

## Usage

The consuming app is **required** to have a `KafkaClientModule` **already initialised**.
Import this producer module either directly to `AppModule` root module or any target module in the following way:

```javascript
import { KafkaProducerModule } from '@dmitrywhite/kafka/producer';
...
imports: [
	...
	KafkaProducerModule,
	...
];
```

This would enable your consuming app to have Kafka Basic Producer service available for usage in the target module.

Then in this target module code the `KafkaProducerService` can be used in the following way:

```javascript
import { KafkaProducerService } from '@dmitrywhite/kafka/producer';
...
constructor(
    ...
    private kafkaBasicProducer: KafkaProducerService,
    ...
) {...}
...
const messageData = {...};
const messageSchema = {...};
...
const result = await this.kafkaBasicProducer.sendSingle(
    {/*some topic object of type ParsedTopic*/},
    messageData,
);

OR

const result = await this.kafkaBasicProducer.sendSingleWithSchema(
    {/*some topic object of type ParsedTopic*/},
    messageData,
    messageSchema,
);
...
```

You can also optionally validate your message data before sending it:

```javascript
const messageData = {...};
const messageSchema = {...};

if (!schema.metadata.isValid(data.value)) {
    throw new UnprocessableEntityException('Data value and schema mismatch');
}
```

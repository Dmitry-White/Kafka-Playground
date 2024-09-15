# @dmitrywhite/kafka/core

This is a TS package that manages topic object definitions and integrates with [AVSC](https://www.npmjs.com/package/avsc) to handle [AVRO IDL 1.11.3](https://avro.apache.org/docs/1.11.3/specification/).
It provides Kafka clients & producers with parsed topics and schemas in various formats along with their metadata to use when sending or preparing to send messages in a typed/validated way.

## Usage

### Topics

Import `TOPICS` object and `TOPIC_NAMES` TS enum and use them both to reference the topics(s) in the following way:

```javascript
import { TOPICS, TOPIC_NAMES } from '@dmitrywhite/kafka/core';
...
const topic = TOPICS[TOPIC_NAMES.EXAMPLE];
```

Or reference a topic based on the env variable:

In `.env`

```plaintext
KAFKA_EXAMPLE_TOPIC_KEY=EXAMPLE # ONE OF: enum TOPIC_NAMES keys OR type TopicKey
```

In `app`

```javascript
import { TOPICS, TOPIC_NAMES, TopicKey } from '@dmitrywhite/kafka/core';
...
this.topicKey = this.configService.get(
  'KAFKA_EXAMPLE_TOPIC_KEY',
) as TopicKey;
...
const topic = TOPICS[TOPIC_NAMES[this.topicKey]];
```

This would enable your consuming app to have access to various details of the referenced topic(s) ready for usage in Kafka Clients and/or Producers.

The following fields in `topic` object are exposed:

- `name` - string representation of the topic, i.e. topic name;
- `json` - local path to JSON representation of the topic, i.e. topic JSON;
- `config` - object representation various configuration values of the topic, i.e. topic object;

### Schemas

Import `PROTOCOLS` object, `PROTOCOL_NAMES` and `SCHEMA_NAMES` TS enums and use them all to reference the schema(s) in the following way:

```javascript
import { PROTOCOLS, PROTOCOL_NAMES, SCHEMA_NAMES } from '@dmitrywhite/kafka/core';
...
const schema = PROTOCOLS[PROTOCOL_NAMES.EXAMPLE].schemas[SCHEMA_NAMES.ExampleEvent];
```

This would enable your consuming app to have access to varios details of the referenced schema(s) ready for usage in Kafka Clients and/or Producers.

The following fields in `schema` object are exposed:

- `avdl` - AVRO AVDL representation of the schema, i.e. custom AVRO IDL schema;
- `avsc` - AVRO AVSC representation of the schema, i.e. custom JSON object;
- `metadata` - various configuration values and utils of the schema;

The following fields in `protocol` object are exposed:

- `avpr` - AVRO AVPR representation of the protocol, i.e. custom AVRO IDL protocol;
- `schemas` - all the schemas grouped together under this protocol, i.e. map of `schema` names and their respective objects;

### Types

Import schema TS types corresponding to schemas in Core module in the following way:

```javascript
import { EventMessage } from '@dmitrywhite/kafka/basic-producer';
import { PROTOCOLS, PROTOCOL_NAMES, SCHEMA_NAMES } from '@dmitrywhite/kafka/core';
import { ExampleEvent } from '@dmitrywhite/kafka/core/types';

...

const value: ExampleEvent = {
  test: 420,
};

const event: EventMessage = {
  key: 'unique',
  value,
};

const schema = PROTOCOLS[PROTOCOL_NAMES.EXAMPLE].schemas[SCHEMA_NAMES.ExampleEvent];
if (!schema.metadata.isValid(event.value)) {
  throw new UnprocessableEntityException('Never as event value is valid');
}
```

This would enable your consuming app to have access to schema TS types that were generated post-build from the same AVRO IDL files ready for usage in Kafka Producers/Consumers.

## Extension

This package can be extended in 5 major ways:

- by modifying existing schemas;
- by adding new schemas.
- by adding new protocols.
- by modifying existing topics;
- by adding new topics.

### Modifying Schemas

To modify any existing schema:

- access target `.avdl` protocol file in `./protocols` folder;
- refer to [AVRO IDL 1.11.3](https://avro.apache.org/docs/1.11.3/specification/) scpecification;
- keep in mind differences in type systems between TS and AVRO IDL;
- keep in mind AVRO IDL specification [naming restrictions](https://avro.apache.org/docs/1.11.3/specification/#names);
- keep in mind [schema evolution](https://docs.confluent.io/platform/current/schema-registry/fundamentals/schema-evolution.html), i.e. versioning & compatibility;
- perform changes;
- publish changes:
  - manually via [Schema Registry API](https://docs.confluent.io/platform/current/schema-registry/develop/using.html);
  - manually via Schema Registry UI;;
  - (preferred)automatically when consuming apps reference this modified schema in their Kafka Client instance;

### Adding Schemas

To add a new schema:

- access target `.avdl` file in `./protocols` folder;
- refer to [AVRO IDL 1.11.3](https://avro.apache.org/docs/1.11.3/specification/) scpecification;
- keep in mind differences in type systems between TS and AVRO IDL;
- keep in mind AVRO IDL specification [naming restrictions](https://avro.apache.org/docs/1.11.3/specification/#names);
- add the any schema name(s) in `SCHEMA_NAMES` enum in `./core.constants.ts` (corresponds to the schema names used in `.avdl` protocol file);
- publish changes:
  - (preferred) automatically when consuming apps reference the new schema(s) in their Kafka Client instance;
  - manually via [Schema Registry API](https://docs.confluent.io/platform/current/schema-registry/develop/using.html);
  - manually via Schema Registry UI;

### Adding Protocols

To add a new protocol:

- go into `./protocols` folder;
- refer to [AVRO IDL 1.11.3](https://avro.apache.org/docs/1.11.3/specification/) scpecification;
- keep in mind differences in type systems between TS and AVRO IDL;
- keep in mind AVRO IDL specification [naming restrictions](https://avro.apache.org/docs/1.11.3/specification/#names);
- add new `.avdl` protocol file;
- in `./core.constants.ts`:
  - add the new protocol name in `PROTOCOL_NAMES` enum;
  - add any new schema name(s) in `SCHEMA_NAMES` enum (corresponds to the schema names used in `.avdl` protocol file);
- export the new protocol details in `PROTOCOLS` object in `./index.ts`;
- publish changes:
  - (preferred) automatically when consuming apps reference this protocol's schema(s) in their Kafka Client instance;
  - manually via [Schema Registry API](https://docs.confluent.io/platform/current/schema-registry/develop/using.html);
  - manually via Schema Registry UI;

### Modifying Topics

To modify any existing topic:

- access target `.json` protocol file in `./topics` folder;
- refer to [Apache Kafka](https://kafka.apache.org/documentation.html#topicconfigs) documentation;
- keep in mind Kafka JS library [topic config defaults](https://kafka.js.org/docs/admin#create-topics);
- perform changes;
- publish changes:
  - (preferred) automatically when consuming apps reference this modified topic in their Kafka Client instance;
  - manually via [Kafka Admin API](https://kafka.apache.org/documentation.html#adminapi);
  - manually via Kafka Broker UI;

### Adding Topics

To add a new topic:

- go into `./topics` folder;
- refer to [Apache Kafka](https://kafka.apache.org/documentation.html#topicconfigs) documentation;
- keep in mind Kafka JS library [topic config defaults](https://kafka.js.org/docs/admin#create-topics);
- add new `.json` topic file;
- add the new topic name in `TOPIC_NAMES` enum in `./core.constants.ts`;
- export the new topics details in `TOPICS` object in `./index.ts`;
- publish changes:
  - (preferred) automatically when consuming apps reference the new topic(s) in their Kafka Client instance;
  - manually via [Kafka Admin API](https://kafka.apache.org/documentation.html#adminapi);
  - manually via Kafka Broker UI;

## Compatibility

This lib has a hard dependency on both `avsc` and `avro-ts` (which also depends on `avsc`) libaraies for converting AVRO IDL files into JSON and TS respectively.

`avsc` in turn depends on a specific version of AVRO IDL, in particular [AVRO IDL 1.11.3](https://avro.apache.org/docs/1.11.3/specification/). For more information, refer to `avsc` [pom.xml file](https://github.com/mtth/avsc/blob/master/etc/integration/pom.xml#L29-L33).

`avsc` version used has a limitation of [reading protocols synchronously](https://github.com/mtth/avsc/wiki/API#readprotocolspec-opts) without an ability to use [AVRO IDL import statements](https://avro.apache.org/docs/1.11.3/idl-language/#imports).

AVRO IDL 1.11.3 is only able to work with `.avdl` files that [define protocols](https://avro.apache.org/docs/1.11.3/idl-language/#defining-a-protocol-in-avro-idl) and can't use `.avdl` files that define raw schemas unlike [latest version](https://avro.apache.org/docs/++version++/idl-language/#defining-a-schema-in-avro-idl). Since `avsc` is not using latest version of AVRO IDL yet, it's not possible to use `.avdl` file to define raw schemas outside protocols definitions.

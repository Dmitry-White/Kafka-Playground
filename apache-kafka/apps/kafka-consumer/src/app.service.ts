import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SchemaRegistryAPIClientArgs } from '@kafkajs/confluent-schema-registry/dist/api';
import { SchemaRegistry, SchemaType } from '@kafkajs/confluent-schema-registry';
import { Consumer, Kafka, KafkaConfig, KafkaMessage } from 'kafkajs';

import { name } from '../package.json';

import { EXAMPLE_SCHEMA, KAFKA_SASL_MECHANISM } from './app.constants';

@Injectable()
export class AppService implements OnModuleInit {
  private kafka: Kafka;
  private schemaRegistry: SchemaRegistry;
  private brokerUri: string;
  private schemaRegistryUri: string;
  private username: string;
  private password: string;
  private kafkaTopic: string;
  private kafkaGroup: string;
  private consumer: Consumer;

  constructor(private readonly configService: ConfigService) {
    this.brokerUri = this.configService.get<string>('KAFKA_BROKER_URI');
    this.schemaRegistryUri = this.configService.get<string>('KAFKA_SCHEMA_REGISTRY_URI');
    this.username = this.configService.get<string>('KAFKA_USERNAME');
    this.password = this.configService.get<string>('KAFKA_PASSWORD');
    this.kafkaTopic = this.configService.get<string>('KAFKA_TOPIC');
    this.kafkaGroup = this.configService.get<string>('KAFKA_GROUP');
  }

  async onModuleInit() {
    this.kafka = this.configureKafka();
    this.schemaRegistry = this.configureSchemaRegistry();

    await this.schemaRegistry.register({
      type: SchemaType.AVRO,
      schema: EXAMPLE_SCHEMA
    });

    this.consumer = this.kafka.consumer({ groupId: this.kafkaGroup });
    await this.consumer.connect();

    await this.consumer.subscribe({
      topic: this.kafkaTopic,
      fromBeginning: true,
    });

    await this.consumer.run({ eachMessage: this.handleMessage });
  }

  private configureKafka(): Kafka {
    const config: KafkaConfig = {
      clientId: name,
      brokers: [this.brokerUri],
      ssl: {
        rejectUnauthorized: false,
      },
      sasl: {
        mechanism: KAFKA_SASL_MECHANISM,
        username: this.username,
        password: this.password,
      },
    };

    return new Kafka(config);
  }

  private configureSchemaRegistry(): SchemaRegistry {
    const config: SchemaRegistryAPIClientArgs = {
      host: this.schemaRegistryUri,
      auth: {
        username: this.username,
        password: this.password,
      },
    };

    return new SchemaRegistry(config);
  }

  private handleMessage = async ({ topic, partition, message }) => {
    const decodedValue = await this.schemaRegistry.decode(message.value);
    const decodedMessage = {
      key: message.key.toString(),
      value: decodedValue,
    };
    console.log({
      topic,
      partition,
      message: decodedMessage,
    });
  }
}

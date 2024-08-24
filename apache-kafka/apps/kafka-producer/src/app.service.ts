import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SchemaRegistry, SchemaType } from '@kafkajs/confluent-schema-registry';
import { SchemaRegistryAPIClientArgs } from '@kafkajs/confluent-schema-registry/dist/api';
import { Kafka, KafkaConfig, Message, Producer, RecordMetadata } from 'kafkajs';

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
  private schemaId: number;
  private producer: Producer;

  constructor(private readonly configService: ConfigService) {
    this.brokerUri = this.configService.get<string>('KAFKA_BROKER_URI');
    this.schemaRegistryUri = this.configService.get<string>('KAFKA_SCHEMA_REGISTRY_URI');
    this.username = this.configService.get<string>('KAFKA_USERNAME');
    this.password = this.configService.get<string>('KAFKA_PASSWORD');
    this.kafkaTopic = this.configService.get<string>('KAFKA_TOPIC');
  }

  async onModuleInit() {
    this.kafka = this.configureKafka();
    this.schemaRegistry = this.configureSchemaRegistry();
    
    const { id } = await this.schemaRegistry.register({
      type: SchemaType.AVRO,
      schema: EXAMPLE_SCHEMA
    });
    this.schemaId = id;

    this.producer = this.kafka.producer();
    await this.producer.connect();
  }

  async sendMessage(data: Message): Promise<RecordMetadata[]> {
    console.log('Data: ', data);

    const outgoingMessage = {
      key: data.key,
      value: await this.schemaRegistry.encode(this.schemaId, data.value)
    }

    const result = await this.producer.send({
      topic: this.kafkaTopic,
      messages: [outgoingMessage],
    });

    console.log('Result: ', result);
    return result;
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
}

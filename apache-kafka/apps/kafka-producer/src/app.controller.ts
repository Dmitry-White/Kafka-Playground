import { Body, Controller, Post } from '@nestjs/common';
import { RecordMetadata } from 'kafkajs';

import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Post()
  send(@Body() body: any): Promise<RecordMetadata[]> {
    return this.appService.sendMessage(body);
  }
}

import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  // '/health' 경로로 GET 요청이 오면 DB 상태를 체크하도록 엔드포인트를 추가
  @Get('/health')
  async checkDbHealth() {
    return this.appService.getDbStatus();
  }
}

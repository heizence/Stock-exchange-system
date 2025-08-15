import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';

@Injectable()
export class AppService {
  constructor(private dataSource: DataSource) {}

  getHello(): string {
    return 'Hello World!';
  }

  // DB 연결 상태를 확인할 새로운 메서드를 추가합니다.
  async getDbStatus() {
    try {
      // 'SELECT NOW()'는 PostgreSQL의 현재 시각을 반환하는 간단한 쿼리입니다.
      // 이 쿼리가 성공하면 연결이 정상인 것입니다.
      const result = await this.dataSource.query('SELECT NOW()');
      return {
        status: 'ok',
        dbTime: result[0].now, // 쿼리 결과에서 시간 값을 추출
      };
    } catch (error) {
      // 쿼리 실행 중 오류가 발생하면 연결에 문제가 있는 것입니다.
      return {
        status: 'error',
        message: error.message,
      };
    }
  }
}

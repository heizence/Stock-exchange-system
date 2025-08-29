import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StocksController } from './stocks.controller';
import { StocksService } from './stocks.service';
import { Stock } from './entities/stock.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Stock])], // Stock 엔티티를 이 모듈에 등록
  controllers: [StocksController],
  providers: [StocksService],
})
export class StocksModule {}

import {
  Controller,
  Get,
  Param,
  NotFoundException,
  HttpStatus,
} from '@nestjs/common';

import { StocksService } from './stocks.service';
import { ResponseDto } from 'src/common/dto/response.dto';

@Controller('stocks')
export class StocksController {
  constructor(private readonly stocksService: StocksService) {}

  @Get(':ticker')
  async findOne(@Param('ticker') ticker: string) {
    const stock = await this.stocksService.findOneByTicker(ticker);
    if (!stock) {
      throw new NotFoundException(`Stock with ticker "${ticker}" not found`);
    }
    return new ResponseDto(HttpStatus.OK, 'Stock found successfully', stock);
  }
}

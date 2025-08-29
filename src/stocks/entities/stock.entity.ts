import { Entity, PrimaryGeneratedColumn, Column, Index } from 'typeorm';

@Entity('stocks')
export class Stock {
  @PrimaryGeneratedColumn('increment')
  id: number;

  @Index({ unique: true })
  @Column({ type: 'varchar', length: 10, unique: true, nullable: false })
  ticker: string;

  @Column({ type: 'varchar', length: 100, nullable: false })
  name: string;

  @Column({ type: 'numeric', precision: 19, scale: 4, nullable: true })
  previous_closing_price: number;

  @Column({ type: 'numeric', precision: 19, scale: 4, nullable: true })
  current_price: number;

  @Column({ type: 'numeric', precision: 19, scale: 4, nullable: true })
  price_change: number;

  @Column({ type: 'numeric', precision: 10, scale: 2, nullable: true })
  price_change_rate: number;

  @Column({ type: 'timestamptz', nullable: true })
  last_updated_at: Date;

  @Column({ type: 'bigint', nullable: true })
  total_volume_today: number;
}

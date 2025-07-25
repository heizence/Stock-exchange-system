-- =================================================================
-- 주식 거래 시스템 데이터베이스 스키마 (PostgreSQL)
-- =================================================================

-- -----------------------------------------------------
-- Table `users` (사용자)
-- : 사용자의 인증 및 식별 정보를 저장한다.
-- -----------------------------------------------------
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE users IS '시스템 사용자 정보';
COMMENT ON COLUMN users.id IS '사용자 고유 ID';
COMMENT ON COLUMN users.username IS '로그인 시 사용할 아이디';
COMMENT ON COLUMN users.password_hash IS '해시된 사용자 비밀번호';
COMMENT ON COLUMN users.created_at IS '가입 시각';


-- -----------------------------------------------------
-- Table `accounts` (계좌)
-- : 사용자의 금융 자산(예치금)을 관리한다.
-- -----------------------------------------------------
CREATE TABLE accounts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    balance NUMERIC(19, 4) NOT NULL DEFAULT 0.00 CHECK (balance >= 0)
);

COMMENT ON TABLE accounts IS '사용자 계좌 및 예치금 정보';
COMMENT ON COLUMN accounts.id IS '계좌 고유 ID';
COMMENT ON COLUMN accounts.user_id IS '계좌 소유자 ID (FK)';
COMMENT ON COLUMN accounts.balance IS '예치금 잔고';


-- -----------------------------------------------------
-- Table `stocks` (주식 종목)
-- : 거래 가능한 모든 주식 종목의 마스터 데이터를 저장한다.
-- -----------------------------------------------------
CREATE TABLE stocks (
    id BIGSERIAL PRIMARY KEY,
    ticker VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    current_price NUMERIC(19, 4),
    price_change NUMERIC(19, 4),
    price_change_rate NUMERIC(10, 2),
    last_updated_at TIMESTAMPTZ,
    total_volume_today BIGINT
);

COMMENT ON TABLE stocks IS '주식 종목 마스터 데이터';
COMMENT ON COLUMN stocks.ticker IS '종목 코드 (e.g., AAPL)';
COMMENT ON COLUMN stocks.name IS '종목 공식 명칭';
COMMENT ON COLUMN stocks.current_price IS '현재가';
COMMENT ON COLUMN stocks.price_change IS '전일 대비 가격 변동';
COMMENT ON COLUMN stocks.price_change_rate IS '전일 대비 등락률 (%)';
COMMENT ON COLUMN stocks.last_updated_at IS '가격 갱신 시각';
COMMENT ON COLUMN stocks.total_volume_today IS '오늘의 누적 거래량';


-- -----------------------------------------------------
-- Table `orders` (주문)
-- : 사용자의 모든 매수/매도 요청을 기록하며, 파티셔닝을 적용한다.
-- -----------------------------------------------------
CREATE TABLE orders (
    id BIGSERIAL,
    user_id BIGINT NOT NULL REFERENCES users(id),
    stock_id BIGINT NOT NULL REFERENCES stocks(id),
    order_type VARCHAR(4) NOT NULL CHECK (order_type IN ('BUY', 'SELL')),
    price NUMERIC(19, 4) NOT NULL CHECK (price > 0),
    quantity BIGINT NOT NULL CHECK (quantity > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, created_at)  -- 파티션 키를 기본 키에 포함
) PARTITION BY RANGE (created_at);

COMMENT ON TABLE orders IS '사용자의 모든 주문 요청 기록';
COMMENT ON COLUMN orders.status IS '주문 상태 (PENDING, COMPLETED, CANCELED 등)';


-- -----------------------------------------------------
-- Table `trades` (체결 내역)
-- : 성공적으로 체결된 모든 거래를 기록하는 원장이며, 파티셔닝을 적용한다.
-- -----------------------------------------------------
CREATE TABLE trades (
    id BIGSERIAL,
    stock_id BIGINT NOT NULL REFERENCES stocks(id),
    price NUMERIC(19, 4) NOT NULL,
    quantity BIGINT NOT NULL,
    buy_order_id BIGINT NOT NULL REFERENCES orders(id),
    sell_order_id BIGINT NOT NULL REFERENCES orders(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, created_at) -- 파티션 키를 기본 키에 포함
) PARTITION BY RANGE (created_at);

COMMENT ON TABLE trades IS '체결된 모든 거래 기록 원장';


-- =================================================================
-- 파티션 테이블 생성 (예시)
-- : 실제 운영 시에는 스케줄러를 통해 매월 또는 매일 자동으로 생성해야 한다.
-- =================================================================
CREATE TABLE trades_y2025m07 PARTITION OF trades FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');
CREATE TABLE orders_y2025m07 PARTITION OF orders FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');


-- =================================================================
-- 인덱스(Index) 생성
-- : 주요 조회 성능 최적화를 위해 인덱스를 생성한다.
-- =================================================================

-- 로그인 시 사용자 조회를 위한 인덱스
CREATE INDEX idx_users_username ON users(username);

-- 주문 시 종목 조회를 위한 인덱스
CREATE INDEX idx_stocks_ticker ON stocks(ticker);

-- 사용자별 주문 내역 조회를 위한 인덱스
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- 매칭 엔진이 체결할 주문을 빠르게 찾기 위한 복합 인덱스
CREATE INDEX idx_orders_matching ON orders(stock_id, status, price, created_at);

-- 특정 종목의 과거 거래 내역 조회를 위한 인덱스
CREATE INDEX idx_trades_stock_id_created_at ON trades(stock_id, created_at DESC);
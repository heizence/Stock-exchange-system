# 1. 기반 이미지 설정 (베이스캠프)
# Node.js 22-alpine 버전을 기반으로 이미지를 생성
FROM node:22-alpine

# 2. 작업 디렉토리 설정
# 컨테이너 내부에 /usr/src/app 이라는 폴더를 만들고, 앞으로의 모든 작업을 이 폴더 안에서 수행
WORKDIR /usr/src/app

# 3. 의존성 파일 복사 및 설치 (효율적인 캐싱)
# package.json과 package-lock.json 파일을 먼저 복사
COPY package*.json ./
# npm install을 실행하여 의존성 패키지를 설치
RUN npm install

# 4. 소스 코드 복사
# 프로젝트의 모든 파일(.)을 컨테이너의 현재 폴더(.)로 복사
COPY . .

# 5. 애플리케이션 빌드
# NestJS(TypeScript) 코드를 실행 가능한 JavaScript 코드로 컴파일(빌드)
RUN npm run build

# 6. 애플리케이션 실행
# 컨테이너가 시작될 때 최종적으로 실행할 명령어를 정의
CMD ["node", "dist/main"]
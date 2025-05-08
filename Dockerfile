# 1. 경량 nginx 이미지 사용
FROM nginx:alpine

# 2. Flutter build 파일들을 nginx가 제공하는 기본 웹 루트로 복사
COPY build/web /usr/share/nginx/html

# 3. 포트 노출
EXPOSE 80

# 4. nginx 시작
CMD ["nginx", "-g", "daemon off;"]
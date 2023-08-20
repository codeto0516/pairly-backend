# ベースイメージを指定
FROM ruby:3.1.4

# 作業ディレクトリを設定
WORKDIR /myapp

RUN apt-get update -qq && apt-get install -y \
    default-mysql-client \
    nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ホストのGemfileとGemfile.lockをコンテナ内にコピー
COPY Gemfile Gemfile.lock /myapp/
RUN bundle install
COPY . /myapp

# nginx
RUN groupadd nginx
RUN useradd -g nginx nginx
ADD nginx.conf /etc/nginx/nginx.conf
EXPOSE 80

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["/usr/bin/entrypoint.sh"]
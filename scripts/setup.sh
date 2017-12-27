source ../.env \
    && dropdb $DB_NAME || true \
    && createdb $DB_NAME \
    && psql --dbname=$DB_NAME --file=../src/backend/init.sql

import os
import time
import uuid
from dataclasses import dataclass
from typing import Optional

import psycopg
from psycopg.rows import dict_row
import redis


@dataclass(frozen=True)
class PgConfig:
    host: str
    port: int
    db: str
    user: str
    password: str


@dataclass(frozen=True)
class RedisConfig:
    host: str
    port: int


def _env(name: str, default: Optional[str] = None) -> str:
    val = os.getenv(name, default)
    if val is None or val == "":
        raise RuntimeError(f"Missing required env var: {name}")
    return val


def load_pg() -> PgConfig:
    return PgConfig(
        host=_env("POSTGRES_HOST"),
        port=int(_env("POSTGRES_PORT", "5432")),
        db=_env("POSTGRES_DB"),
        user=_env("POSTGRES_USER"),
        password=_env("POSTGRES_PASS"),
    )


def load_redis() -> Optional[RedisConfig]:
    host = os.getenv("REDIS_HOST")
    if not host:
        return None
    return RedisConfig(
        host=host,
        port=int(_env("REDIS_PORT", "6379")),
    )


def pg_dsn(cfg: PgConfig) -> str:
    return f"host={cfg.host} port={cfg.port} dbname={cfg.db} user={cfg.user} password={cfg.password}"


def ensure_schema(conn: psycopg.Connection):
    with conn.cursor() as cur:
        cur.execute(
            """
            create table if not exists worker_heartbeat (
              id bigserial primary key,
              worker_id text not null,
              ts timestamptz not null default now()
            );
            """
        )
    conn.commit()


def main():
    worker_id = os.getenv("WORKER_ID") or str(uuid.uuid4())
    interval_s = float(os.getenv("INTERVAL_SECONDS", "5"))

    pg = load_pg()
    r_cfg = load_redis()

    print(
        f"[worker] id={worker_id} interval={interval_s}s pg={pg.host}:{pg.port}/{pg.db} redis={'yes' if r_cfg else 'no'}"
    )

    while True:
        try:
            with psycopg.connect(
                pg_dsn(pg), connect_timeout=2, row_factory=dict_row
            ) as conn:
                ensure_schema(conn)
                with conn.cursor() as cur:
                    cur.execute(
                        "insert into worker_heartbeat (worker_id) values (%s) returning ts;",
                        (worker_id,),
                    )
                    ts = cur.fetchone()["ts"]
                conn.commit()
            print(f"[worker] wrote heartbeat ts={ts}")
        except Exception as e:
            print(f"[worker] postgres error: {e.__class__.__name__}: {e}")

        if r_cfg:
            try:
                rr = redis.Redis(
                    host=r_cfg.host,
                    port=r_cfg.port,
                    socket_connect_timeout=2,
                    socket_timeout=2,
                )
                rr.setex(
                    f"worker:{worker_id}:last_seen",
                    int(interval_s * 3),
                    str(int(time.time())),
                )
                print("[worker] redis set last_seen")
            except Exception as e:
                print(f"[worker] redis error: {e.__class__.__name__}: {e}")

        time.sleep(interval_s)


if __name__ == "__main__":
    main()

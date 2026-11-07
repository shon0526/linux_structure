FROM ubuntu:24.04

ARG USERNAME=ubuntu

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 基本ツール（Rust のビルドに必要な C コンパイラ・リンカなど）
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        pkg-config \
        libssl-dev \
        sudo \
        tzdata \
        sysstat \
        strace \
        lld \
    && rm -rf /var/lib/apt/lists/*

# 作業ユーザー（ubuntu:24.04 には ubuntu ユーザー(UID/GID 1000)が最初から入っているのでそれを使う）
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}

ENV PATH=/home/${USERNAME}/.cargo/bin:${PATH}
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --profile minimal --default-toolchain none \
    # crate のキャッシュ用ボリュームのマウント先（dev ユーザー所有で作っておく）
    && mkdir -p ~/.cargo/registry ~/.cargo/git

# rust-toolchain.toml で固定したバージョンとコンポーネントを事前にインストールし、
# /workspace 以外でも同じバージョンを使うようデフォルトに設定
WORKDIR /workspace
COPY --chown=${USERNAME}:${USERNAME} rust-toolchain ./
RUN rustup toolchain install \
    && rustup default "$(rustup show active-toolchain | cut -d' ' -f1)"

CMD ["bash"]

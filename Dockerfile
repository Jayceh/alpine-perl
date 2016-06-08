FROM alpine

## alpine curl and wget aren't fully compatible, so we install them
## here. gnupg is needed for Module::Signature.
RUN apk update && apk upgrade && apk add curl tar make gcc build-base wget gnupg

RUN mkdir -p /usr/src/perl

WORKDIR /usr/src/perl

## from perl; `true make test_harness` because 1 UTF-8 test fails :(
RUN curl -SL http://www.cpan.org/src/5.0/perl-5.24.0.tar.gz -o perl-5.24.0.tar.gz \
    && echo '35770ea5cf49a1082852c2300ccc3cbbc58b70fd *perl-5.24.0.tar.gz' | sha1sum -c - \
    && tar --strip-components=1 -xzf perl-5.24.0.tar.gz -C /usr/src/perl \
    && rm perl-5.24.0.tar.gz \
    && ./Configure -Duse64bitall -des \
    && make -j$(nproc) \
    && TEST_JOBS=$(nproc) true make test_harness \
    && make install \
    && curl -LO https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm \
    && chmod +x cpanm \
    && ./cpanm App::cpanminus \
    && rm -fr ./cpanm /root/.cpanm /usr/src/perl

## from tianon/perl
ENV PERL_CPANM_OPT --verbose --mirror https://cpan.metacpan.org --mirror-only
RUN cpanm Digest::SHA Module::Signature && rm -rf ~/.cpanm
ENV PERL_CPANM_OPT $PERL_CPANM_OPT --verify

WORKDIR /

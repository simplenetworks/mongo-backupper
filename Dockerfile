FROM mongo:3.4.7

RUN apt-get update && \
    apt-get install -y cron ncftp lftp && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD backup.sh /backup.sh
ADD clean-old-backups.sh /clean-old-backups.sh
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chmod +x /backup.sh && chmod +x /clean-old-backups.sh

RUN mkdir -p ~/.lftp
RUN echo "set ssl:verify-certificate noset ftp:ssl-allow no" > ~/.lftp/rc

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
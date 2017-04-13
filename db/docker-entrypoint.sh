#!/bin/bash
set -eo pipefail
# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
	set -- mysqld "$@"
fi

if [ "$1" = 'mysqld' ]; then
	# Get config
	DATADIR="$("$@" --verbose --help 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')"

	if [ ! -d "$DATADIR/mysql" ]; then
		if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" -a -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
			echo >&2 'error: database is uninitialized and password option is not specified '
			echo >&2 '  You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD'
			exit 1
		fi

		mkdir -p "$DATADIR"
		chown -R mysql:mysql "$DATADIR"

		echo 'Initializing database'
		"$@" --initialize-insecure
		echo 'Database initialized'

		"$@" --skip-networking &
		pid="$!"

		mysql=( mysql --protocol=socket -uroot )

		for i in {30..0}; do
			if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
				break
			fi
			echo 'MySQL init process in progress...'
			sleep 1
		done
		if [ "$i" = 0 ]; then
			echo >&2 'MySQL init process failed.'
			exit 1
		fi

		if [ -n "${REPLICATION_MASTER}" ]; then
			echo "=> Configuring MySQL replication as master (1/2) ..."
			if [ ! -f /replication_set.1 ]; then
		        	echo "=> Writting configuration file /etc/mysql/my.cnf with server-id=1"
			        echo 'server-id = 1' >> /etc/mysql/mysql.conf.d/mysqld.cnf
			        echo 'log-bin = mysql-bin' >> /etc/mysql/mysql.conf.d/mysqld.cnf
		        	touch /replication_set.1
				cat /etc/mysql/mysql.conf.d/mysqld.cnf
	    		else
		        	echo "=> MySQL replication master already configured, skip"
			fi
		fi
		# Set MySQL REPLICATION - SLAVE
		if [ -n "${REPLICATION_SLAVE}" ]; then
		    echo "=> Configuring MySQL replication as slave (1/2) ..."
		    if [ -n "${MYSQL_PORT_3306_TCP_ADDR}" ] && [ -n "${MYSQL_PORT_3306_TCP_PORT}" ]; then
		        if [ ! -f /replication_set.1 ]; then
		            echo "=> Writting configuration file /etc/mysql/my.cnf with server-id=2"
		            echo 'server-id = 2' >> /etc/mysql/my.cnf
		            echo 'log-bin = mysql-bin' >> /etc/mysql/my.cnf
                    echo 'log-bin=slave-bin' >> /etc/mysql/my.cnf
		            touch /replication_set.1
		        else
		            echo "=> MySQL replication slave already configured, skip"
		        fi
		    else
		        echo "=> Cannot configure slave, please link it to another MySQL container with alias as 'mysql'"
		        exit 1
		    fi
		fi

		# Set MySQL REPLICATION - SLAVE
		if [ -n "${REPLICATION_SLAVE}" ]; then
		    echo "=> Configuring MySQL replication as slave (2/2) ..."
		    if [ -n "${MYSQL_PORT_3306_TCP_ADDR}" ] && [ -n "${MYSQL_PORT_3306_TCP_PORT}" ]; then
		        if [ ! -f /replication_set.2 ]; then
		            echo "=> Setting master connection info on slave"
			echo "!!! DEBUG: ${REPLICATION_USER}, ${REPLICATION_PASS}."
				"${mysql[@]}" <<-EOSQL
					-- What's done in this file shouldn't be replicated
					--  or products like mysql-fabric won't work
					SET @@SESSION.SQL_LOG_BIN=0;
					CHANGE MASTER TO MASTER_HOST='${MYSQL_PORT_3306_TCP_ADDR}',MASTER_USER='${REPLICATION_USER}',MASTER_PASSWORD='${REPLICATION_PASS}',MASTER_PORT=${MYSQL_PORT_3306_TCP_PORT}, MASTER_CONNECT_RETRY=30;
					START SLAVE ;
				EOSQL

		            echo "=> Done!"
		            touch /replication_set.2
		        else
		            echo "=> MySQL replication slave already configured, skip"
		        fi
		    else
		        echo "=> Cannot configure slave, please link it to another MySQL container with alias as 'mysql'"
		        exit 1
		    fi
		fi


		if [ -z "$MYSQL_INITDB_SKIP_TZINFO" ]; then
			# sed is for https://bugs.mysql.com/bug.php?id=20545
			mysql_tzinfo_to_sql /usr/share/zoneinfo | sed 's/Local time zone must be set--see zic manual page/FCTY/' | "${mysql[@]}" mysql
		fi

		if [ ! -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
			MYSQL_ROOT_PASSWORD="$(pwgen -1 32)"
			echo "GENERATED ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
		fi
		"${mysql[@]}" <<-EOSQL
			-- What's done in this file shouldn't be replicated
			--  or products like mysql-fabric won't work
			SET @@SESSION.SQL_LOG_BIN=0;

			DELETE FROM mysql.user ;
			CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
			GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
			DROP DATABASE IF EXISTS test ;
			FLUSH PRIVILEGES ;
		EOSQL

		if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
			mysql+=( -p"${MYSQL_ROOT_PASSWORD}" )
		fi

		# Set MySQL REPLICATION - MASTER
		if [ -n "${REPLICATION_MASTER}" ]; then
		    echo "=> Configuring MySQL replication as master (2/2) ..."
		    if [ ! -f /replication_set.2 ]; then
		        echo "=> Creating a log user ${REPLICATION_USER}:${REPLICATION_PASS}"

				"${mysql[@]}" <<-EOSQL
					-- What's done in this file shouldn't be replicated
					--  or products like mysql-fabric won't work
					SET @@SESSION.SQL_LOG_BIN=0;

					CREATE USER '${REPLICATION_USER}'@'%' IDENTIFIED BY '${REPLICATION_PASS}';
					GRANT REPLICATION SLAVE ON *.* TO '${REPLICATION_USER}'@'%' ;
					FLUSH PRIVILEGES ;
					RESET MASTER ;
				EOSQL

		        echo "=> Done!"
		        touch /replication_set.2
		    else
		        echo "=> MySQL replication master already configured, skip"
		    fi
		fi


		if [ "$MYSQL_DATABASE" ]; then
			echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"
			mysql+=( "$MYSQL_DATABASE" )
		fi

		if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
			echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" | "${mysql[@]}"

			if [ "$MYSQL_DATABASE" ]; then
				echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" | "${mysql[@]}"
			fi

			echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"
		fi

		echo
		for f in /docker-entrypoint-initdb.d/*; do
			case "$f" in
				*.sh)     echo "$0: running $f"; . "$f" ;;
				*.sql)    echo "$0: running $f"; "${mysql[@]}" < "$f"; echo ;;
				*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${mysql[@]}"; echo ;;
				*)        echo "$0: ignoring $f" ;;
			esac
			echo
		done

		if [ ! -z "$MYSQL_ONETIME_PASSWORD" ]; then
			"${mysql[@]}" <<-EOSQL
				ALTER USER 'root'@'%' PASSWORD EXPIRE;
			EOSQL
		fi
		if ! kill -s TERM "$pid" || ! wait "$pid"; then
			echo >&2 'MySQL init process failed.'
			exit 1
		fi

		echo
		echo 'MySQL init process done. Ready for start up.'
		echo
	fi

	chown -R mysql:mysql "$DATADIR"
fi

exec "$@"

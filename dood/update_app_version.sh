#!/bin/bash

# 更新数据库
update_database() {
  if [[ -f /opt/1panel/db/core.db ]]; then
    # 对比版本
    DB_VERSION=$(sqlite3 /opt/1panel/db/core.db "SELECT value FROM settings WHERE key = 'SystemVersion'")
    PANEL_VERSION=$PANELVER
    if [[ "$DB_VERSION" == "$PANEL_VERSION" ]]; then
      echo "Database version: $PANEL_VERSION is already up-to-date, no update needed."
      exit 0
    fi

    # 备份数据库文件
    if [[ -f /opt/1panel/db/core.db.bak ]]; then
      rm -f /opt/1panel/db/core.db.bak
    fi
    cp /opt/1panel/db/core.db /opt/1panel/db/core.db.bak

    # 使用 sqlite3 执行更新操作
    sqlite3 /opt/1panel/db/core.db <<EOF
UPDATE settings
SET value = '$PANEL_VERSION'
WHERE key = 'SystemVersion';
.exit
EOF

    echo "Database version has been updated to $PANEL_VERSION."
  else
    echo "Database is not initialized, no update needed."
    exit 0
  fi
}

# 主函数
main() {
    update_database
}

# 调用主函数
main
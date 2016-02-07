#/bin/bash
REV=$1

echo $REV > public/version

echo "[Escualo::Atheneum] Running Migrations..."
rake db:migrate

echo "[Escualo::Atheneum] Compiling assets..." 
rake assets:precompile

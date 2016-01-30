#!/bin/sh

echo "UPDATE est SET type = 'U';" | mysql $1

echo "UPDATE est SET type = 'T' where description LIKE \"%3 prime%\";" | mysql $1
echo "UPDATE est SET type = 'T' where description LIKE \"%3'%\";" | mysql $1
echo "UPDATE est SET type = 'T' where description LIKE \"%3&apos;%\";" | mysql $1
echo "UPDATE est SET type = 'T' where clone RLIKE \"p3$\";" | mysql $1
  echo "UPDATE est SET clone = substring(clone,1,(length(clone)-2)) where clone RLIKE \"p3$\";" | mysql $1

echo "UPDATE est SET type = 'F' where description LIKE \"%5 prime%\";" | mysql $1
echo "UPDATE est SET type = 'F' where description LIKE \"%5'%\";" | mysql $1
echo "UPDATE est SET type = 'F' where description LIKE \"%5&apos;%\";" | mysql $1
echo "UPDATE est SET type = 'F' where clone RLIKE \"p5$\";" | mysql $1
  echo "UPDATE est SET clone = substring(clone,1,(length(clone)-2)) where clone RLIKE \"p5$\";" | mysql $1





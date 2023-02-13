### Описание

Shell-скрипт (backupss - backup shell script) для создания резервных копий выбранных директорий и файлов. Требовалось создать простой и прозрачный скрипт для создания резервных копий. На момент написания скрипта подобных программ в сети интернет я не нашел. <br />
Может создавать дифференциальные и инкрементные архивы. 

В *backup.cfg* необходимо указать <br />
*files_to_backup* - что копировать <br />
*backup_location* - куда сохранить <br />

В *exclude.list* необходимо перечислить пути к файлам, директориям, которые не будут включены в резервную копию. <br />

В рабочей директории в процессе выполнения копирования будут созданы лог файлы: *backup.log*, *tar.log*. <br />

### Пример

Полный архив без сжатия
```sh
./backup.sh -d
```
Последующие дифференциальные архивы со сжатием
```sh
./backup.sh -d -z
```

Для создания инкрементных архивов запускайте скрипт *backup.sh* без параметра *-d*

### Решение проблем
- В редких случаях при создании дифференциального архива начинает создаваться полный архив. Прервите процесс создания, перезагрузите компьютер и попробуйте заново.

Manuel d'utilisation de Align.sh

Pour le lancer il prend en compte 2 arguments : 

Le genome de reference à utiliser sur les fichiers, et le nombre de coeur à allouer à celui-ci.
Il faut être obligatoirement dans le dossier au dessus de 4alignement pour le lancer.

ex : ./4alignement/Align.sh 40 GRCh37

sbatch -N 1 -n 40 -t 7-00 --mem 40GB 4alignement/Align.sh 40 GRCh37

Dans le cas ou vous ne souhaitez pas utiliser les dossier a cette effet vous pouvez utiliser AlignManual.sh
Il prend donc 4-5 arguments:
							Le nombre de coeur allouer
							Le geneme de reference
							La longueur de read pour l'indexation
							Le chemin absolu du premier fastq
							Le chemin absolu du 2eme fastq en cas de pair end

ex: 

./4alignement/AlignManual.sh 30 mm9 100 /path/de/dest/test.fastq /path/de/dest/test2.fastq

sbatch -N 1 -n 40 -t 7-00 --mem 40GB 4alignement/AlignManual.sh 30 mm9 100 /path/de/dest/test /path/de/dest/test2
import cv2
import numpy as np
import subprocess

k=5
aumento_k=5
k_ascii=chr(k)
#agarra el valor de k y lo convierte a ascii para esvribirlo en el archivo K
with open("K","w") as f:
    f.write(k_ascii)

# #Leer imagen
name = input("Elige el nombre de la img: ")
#cargar la imagen
img=cv2.imread(name,0).astype(np.uint8).flatten().tofile("Binario")

for i in range(0,39):
    subprocess.run("./CalcSinVdiv")

    k = k + aumento_k
    k_ascii = chr(k)
    # agarra el valor de k y lo convierte a ascii para esvribirlo en el archivo K
    with open("K", "w") as f:
        f.write(k_ascii)

    #Leer salda del algoritmo
    img = np.fromfile("Output", dtype=np.uint8)
    img = img.reshape(480,640)
    cv2.imwrite("img_generate/output"+str(i)+".png",img)

# Generar animacion con cv. 40 imagenes en 10 segundos
for i in range(0,39):
    img = cv2.imread("img_generate/output"+str(i)+".png")
    cv2.imshow("img",img)
    cv2.waitKey(250)

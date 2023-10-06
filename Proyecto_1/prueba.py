import cv2
import numpy as np

# #Leer imagen
# name = input("Elige el nombre de la img: ")
# #cargar la imagen
# img=cv2.imread(name,0).astype(np.int8).flatten().tofile("Binario")


#Leer salda del algoritmo
img = np.fromfile("Output", dtype=np.uint8)
img = img.reshape(480,640)
#print(img)
cv2.imwrite("Output.png",img)

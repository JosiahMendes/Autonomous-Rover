#include <stdio.h>

const int colour = 5;
const int coords = 4;

char* calcLoc(int arr[colour][coords]){
  char *result = malloc(90);
  for (int i = 0; i<colour; i++){
    printf("test\n");
    double x, y;
    double xcenter, ycenter;
    xcenter = arr[i][2] - arr[i][0];
    ycenter = arr[i][3] - arr[i][1];
    x = -0.0001052450682 * xcenter *xcenter 
    +   -0.0003456971514 * xcenter * ycenter  
    +   -0.0003507027855 * ycenter * ycenter 
    +    0.2239097930601 * xcenter 
    +    0.2615837422115 * ycenter
    +   -48.7190661977359;
    printf("x value = %f \n", x);

    y = -0.0002277836374 * xcenter *xcenter 
    +    0.0005867540874 * xcenter * ycenter  
    +   -0.0003445331302 * ycenter * ycenter 
    +   -0.1792093462712 * xcenter 
    +   -0.1304265702960 * ycenter
    +    154.6050589809311;

    printf("y value = %f \n", y);

    sprintf(result+strlen(result), "%.2f,%.2f;",x, y);
  }
  return result;
}

int main(void) {
  int arr[][4] = {{0,0,0,360},{0,0,0,360}, {0,0,0,360},{0,0,0,360}, {0,0,0,360}};
  char* res = calcLoc(arr);
  printf("%s \n", res);
  free(res);
  return 0;
}
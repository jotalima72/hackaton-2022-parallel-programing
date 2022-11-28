#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <mpi.h>
// 97 to 122 use only lowercase letters
// 65 to 90 use only capital letters
// 48 to 57 use only numbers

#define START_CHAR 48
#define END_CHAR 122
#define MAXIMUM_PASSWORD 20

long long my_pow(long long x, int y)
{
  long long res = 1;
  if (y == 0)
    return res;
  else
    return x * my_pow(x, y - 1);
}

void bruteForce(char *pass, long long int numInit, long long int numEnd)
{
  time_t t1, t2;
  double dif;
  int flag = 0, pass_b26[MAXIMUM_PASSWORD];
  long long int j;
  long long int pass_decimal = 0;
  int base = END_CHAR - START_CHAR + 2;
  time(&t1);
  int size = strlen(pass);

  for (int i = 0; i < size; i++)
    pass_b26[i] = (int)pass[i] - START_CHAR + 1;

  for (int i = size - 1; i > -1; i--)
    pass_decimal += (long long int)pass_b26[i] * my_pow(base, i);

  long long int max = my_pow(base, size);
  char s[MAXIMUM_PASSWORD];

  #pragma omp parallel for private(j)
  for (j = numInit; j < numEnd; j++)
  {
    if (j == pass_decimal)
    {
      printf("Found password!\n");
      int index = 0;

      printf("Password in decimal base: %lli\n", j);
      while (j > 0)
      {
        s[index++] = START_CHAR + j % base - 1;
        j /= base;
      }
      s[index] = '\0';
      printf("Found password: %s\n", s);
      flag = 1;
    }
    if (flag == 1)
    {
      time(&t2);
      dif = difftime(t2, t1);

      printf("\n%1.2f seconds\n", dif);

      MPI_Abort(MPI_COMM_WORLD, 0);
      exit(0);
    }
  }
}

int main(int argc, char **argv)
{
  char password[MAXIMUM_PASSWORD];
  strcpy(password, argv[1]);
  double dif;

  int base = END_CHAR - START_CHAR + 2;
  int size = strlen(password);
  long long int max = my_pow(base, size);

  int numberOfProcessors, id, to, flag = 0, from, tag = 1000;
  int res, val;
  long long int numInit, numEnd;

  MPI_Init(&argc, &argv);
  MPI_Comm_size(MPI_COMM_WORLD, &numberOfProcessors);
  MPI_Comm_rank(MPI_COMM_WORLD, &id);
  MPI_Request request;
  MPI_Status status;

  if (id == 0)
  {
    printf("Try to broke the password: %s\n", password);
    for (to = 1; to < numberOfProcessors; to++)
    {
      numInit = (max / (numberOfProcessors)) * (to);
      numEnd = (max / (numberOfProcessors)) * (to + 1);
      // printf("id(%d) : %lli -> %lli\n",to,numInit, numEnd);
      MPI_Send(&numInit, 1, MPI_LONG, to, tag, MPI_COMM_WORLD);
      MPI_Send(&numEnd, 1, MPI_LONG, to, tag, MPI_COMM_WORLD);
    }
    numInit = 0;
    numEnd = (max / (numberOfProcessors));
    bruteForce(password, numInit, numEnd);
  }
  else
  {
    MPI_Recv(&numInit, 1, MPI_LONG, 0, tag, MPI_COMM_WORLD, &status);
    MPI_Recv(&numEnd, 1, MPI_LONG, 0, tag, MPI_COMM_WORLD, &status);
    bruteForce(password, numInit, numEnd);
  }
  MPI_Finalize();
  return 0;
}
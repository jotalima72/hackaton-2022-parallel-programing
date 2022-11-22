#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <mpi.h>

// 97 to 122 use only lowercase letters
// 65 to 90 use only capital letters
// 48 to 57 use only numbers

#define START_CHAR 97
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

long long int bruteForce(long long int pass, long long int numInit, long long int numEnd)
{
  long long int j;
  int base = END_CHAR - START_CHAR + 2;
  char s[MAXIMUM_PASSWORD];
  int flag = 0;
  long long int aux = 0;
  for (j = numInit; j < numEnd; j++)
  {

    if (j == pass)
    {
      printf("Found password!\n");
      int index = 0;

      printf("Password in decimal base: %lli\n", j);
      aux = j;
      while (j > 0)
      {
        s[index++] = 'a' + j % base - 1;
        j /= base;
      }
      s[index] = '\0';
      printf("Found password: %s\n", s);
      flag = 1;
    }
    if (flag == 1)
    {
      return aux;
    }
  }
  return -1;
}

int main(int argc, char **argv)
{
  time_t t1, t2;
  time(&t1);
  int numberOfProcessors, id, to, from, tag = 1000;
  int res, val;
  long long int numInit, numEnd;

  MPI_Init(&argc, &argv);
  MPI_Comm_size(MPI_COMM_WORLD, &numberOfProcessors);
  MPI_Comm_rank(MPI_COMM_WORLD, &id);
  MPI_Status status;

  char password[MAXIMUM_PASSWORD];
  strcpy(password, argv[1]);
  double dif;

  int base = END_CHAR - START_CHAR + 2;
  int size = strlen(password);
  long long int pass_decimal = 0;
  int pass_b26[MAXIMUM_PASSWORD];

  for (int i = 0; i < size; i++)
    pass_b26[i] = (int)password[i] - START_CHAR + 1;

  for (int i = size - 1; i > -1; i--)
    pass_decimal += (long long int)pass_b26[i] * my_pow(base, i);

  long long int max = my_pow(base, size);

  switch (id)
  {
  case 0:
    printf("Try to broke the password: %s\n", password);
    for (to = 1; to < numberOfProcessors; to++)
    {
      numInit = (max / (numberOfProcessors - 1)) * (to - 1);
      numEnd = (max / (numberOfProcessors - 1)) * to;
      // printf("id(%d) : %lli -> %lli\n",to,numInit, numEnd);
      MPI_Send(&numInit, 1, MPI_LONG, to, tag, MPI_COMM_WORLD);
      MPI_Send(&numEnd, 1, MPI_LONG, to, tag, MPI_COMM_WORLD);
    }

    for (to = 1; to < numberOfProcessors; to++)
    {
      MPI_Recv(&res, 1, MPI_LONG, to, tag, MPI_COMM_WORLD, &status);
    }
    break;

  default:
    MPI_Recv(&numInit, 1, MPI_LONG, 0, tag, MPI_COMM_WORLD, &status);
    MPI_Recv(&numEnd, 1, MPI_LONG, 0, tag, MPI_COMM_WORLD, &status);

    long long int aux = bruteForce(pass_decimal, numInit, numEnd);
    if (aux != -1)
      printf("id(%d) -> aux %lli\n\n", id, aux);
    MPI_Send(&aux, 1, MPI_INT, 0, tag, MPI_COMM_WORLD);
    break;
  }
  time(&t2);
  if (id == 0)
  {
    dif = difftime(t2, t1);
    printf("Execution time - %1.2f seconds\n", dif);
  }
  MPI_Finalize();
  return 0;
}
#include <iostream>
#include <fstream>
#include <math.h>
#include <cstring>
#include <random>
#include <ctime>
#include <algorithm>
using namespace std;
int r, c, l;
void down_samling_meadian(vector<float> arr)
{
    // arr = {2, 5, 4, 1, 7, 4, 7, 2, 10, 11, 20, 7, 7, 12, 4, 8};
    float even[4] = {1.5, 0.5, 0.5, 1.5};
    float odd[4] = {0.5, 1.5, 1.5, 0.5};

    for (int k = 0; k < l; k++)
    {
        vector<float> temp;
        for (int i = 0; i < r * c; i += 2 * c)
        {

            for (int j = 0; j < c; j += 2)
            {
                cout << arr[i + j] << " " << arr[i + j + 1] << " " << arr[i + j + c] << " " << arr[i + j + c + 1] << "\n";

                vector<float> temp1;
                float sum = 0;
                sum += arr[i + j] + arr[i + j + 1] + arr[i + j + c + 1] + arr[i + j + c];
                temp1.push_back(arr[i + j]);
                temp1.push_back(arr[i + j + 1]);
                temp1.push_back(arr[i + j + c]);
                temp1.push_back(arr[i + j + c + 1]);
                sort(temp1.begin(), temp1.end());
                sum -= temp1[0] + temp1[3];
                cout << temp1[0] << " " << temp1[3] << "\n";
                sum /= 2.0;

                cout << sum << endl;
                temp.push_back(sum);
            }
        }
        r /= 2;
        c /= 2;
        arr = temp;
    }
    fstream outfile;
    outfile.open("output_test_cases.txt", ios_base::app);
    outfile << "result for " << l << " levels using median : \n";
    for (auto i : arr)
        outfile << i << " ";
    outfile << "\n############################################################################\n";
    outfile.close();
}
void down_samling_areethmatic_mean(vector<float> arr)
{
    int cn = 0;
    // arr = {2, 5, 4, 1, 7, 4, 7, 2, 10, 11, 20, 7, 7, 12, 4, 8};
    float even[4] = {1.5, 0.5, 0.5, 1.5};
    float odd[4] = {0.5, 1.5, 1.5, 0.5};

    for (int k = 0; k < l; k++)
    {
        vector<float> temp;
        for (int i = 0; i < r * c; i += 2 * c)
        {

            for (int j = 0; j < c; j += 2)
            {
                // cout << arr[i + j] << " " << arr[i + j + 1] << " " << arr[i + j + c] << " " << arr[i + j + c + 1] << "\n";
                float sum = 0;
                if (k % 2 == 0)
                    sum += arr[i + j] * even[0] + arr[i + 1 + j] * even[1] + arr[i + c + j] * even[2] + arr[i + c + 1 + j] * even[3];
                else
                    sum += arr[i + j] * odd[0] + arr[i + 1 + j] * odd[1] + arr[i + c + j] * odd[2] + arr[i + c + 1 + j] * odd[3];
                //  cout << sum << "\n";
                sum /= 4.0;
                cout << cn << "-" << sum << "\n";
                cn++;
                temp.push_back(sum);
            }
        }
        r /= 2;
        c /= 2;
        arr = temp;
    }
    fstream outfile;
    outfile.open("output_test_cases.txt", ios_base::app);
    outfile << "result for " << l << " levels using Arethmatic mean : \n";
    for (auto i : arr)
        outfile << i << " ";
    outfile << "\n############################################################################\n";
    outfile.close();
}
int main()
{

    cout << "please enter the number of rows\n";
    cin >> r;
    cout << "please enter the number of coloumns\n";
    cin >> c;
    cout << "please enter the number of levels\n";
    cin >> l;
    int lTemp, r1 = r, c1 = c;
    while (true)
    {
        if (r1 % 2 != 0)
            break;
        if (c1 % 2 != 0)
            break;
        c1 /= 2;
        r1 /= 2;
        lTemp++;
    }
    if (l > lTemp)
    {
        cout << "the level you enter is incorect\n";
        exit(1);
    }
    fstream outfile;

    outfile.open("output_test_cases.txt", ios_base::app);
    outfile << "\n############################################################################\nsize of the array and array :\n";

    outfile << r << " " << c << "\n";

    vector<float> arr;
    int high = 10;
    int low = 1;

    srand(time(NULL));
    for (int i = 0; i < r; i++)
    {
        for (int j = 0; j < c; j++)
        {
            float random_number = low + static_cast<float>(rand()) *
                                            static_cast<float>(high - low) / RAND_MAX;

            arr.push_back(random_number);
            outfile << random_number;

            if (i == r - 1 && j == c - 1)
                outfile << "\n";
            else
                outfile << " ";
        }
    }
    outfile << "\n";
    outfile.close();
    int choose;
    cout << "1-Arethmatic mean\n2-median\n";
    cin >> choose;
    if (choose == 1)
        down_samling_areethmatic_mean(arr);
    if (choose == 2)
        down_samling_meadian(arr);
    return 0;
}
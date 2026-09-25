#ifndef HBPL_LOG_HOG_CALCULATOR_H
#define HBPL_LOG_HOG_CALCULATOR_H

#include <opencv2/core.hpp>
#include <string>

class LogHogCalculator
{
  public:
    LogHogCalculator();
    LogHogCalculator(double r, int theta_bins, int r_bins, int nthet_bins, const char *issignedFlag,
                     int normFlag);
    virtual ~LogHogCalculator();
    cv::Mat ExtractHogsDiagonal(cv::Mat img);

  protected:
    double radius;
    int nbins_theta;
    int nbins_r;
    int nthet;
    std::string issigned;
    int normmethod; // Historical mode 0 follows mode 1 (L1 normalization).
};

#endif

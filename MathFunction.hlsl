#ifndef MATH_FUNCTION
#define MATH_FUNCTION

// lerpの逆関数
// aとbの値が等しい場合、0で割り算が発生する可能性がある
float inverseLerp(float a, float b, float t)
{
    return (t - a) / (b - a);
}

// 距離の二乗を計算する
// Distanceより早く計算できる
float distSquared(float2 a, float2 b)
{
    float2 c = a - b;
    return dot(c, c);
}

// 値を0~1にclampする
float remap(float val, float2 inMinMax, float2 outMinMax)
{
    return clamp(outMinMax.x + (val - inMinMax.x) * (outMinMax.y - outMinMax.x) / (inMinMax.y - inMinMax.x), outMinMax.x, outMinMax.y);
}

// 回転
float2x2 rot(float a)
{
    return float2x2(cos(a), sin(a), -sin(a), cos(a));
}

#endif

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

// カメラの前方向のベクトルを取得
float3 getCameraForwardDir()
{
    return normalize(-UNITY_MATRIX_V[2].xyz);
}

// 極座標
float2 polar(float2 uv, float2 center = float2(0.0, 0.0), float radialScale = 1.0, float lengthScale = 0.0)
{
    float2 delta = uv - center;
    float radius = length(delta) * 2.0 * radialScale;
    float angle = atan2(delta.x, delta.y) * rcp(6.28) * lengthScale; // rcp(6.28) = 1.0 / 6.28
    return float2(radius, angle);
}

#endif

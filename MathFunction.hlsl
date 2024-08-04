#ifndef MATH_FUNCTION
#define MATH_FUNCTION

// カメラの前方向のベクトルを取得
float3 getCameraForwardDir()
{
    return normalize(-UNITY_MATRIX_V[2].xyz);
}

// オブジェクトのスケールを取得
float3 getObjectScale()
{
    float3 scale = float3(
                            length(float3(unity_ObjectToWorld[0].x , unity_ObjectToWorld[1].x , unity_ObjectToWorld[2].x)),
	                        length(float3(unity_ObjectToWorld[0].y , unity_ObjectToWorld[1].y , unity_ObjectToWorld[2].y)),
	                        length(float3(unity_ObjectToWorld[0].z , unity_ObjectToWorld[1].z , unity_ObjectToWorld[2].z))
                        );
    return scale;
}

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

// 極座標
float2 polar(float2 uv, float2 center = float2(0.0, 0.0), float radialScale = 1.0, float lengthScale = 1.0)
{
    float2 delta = uv - center;
    float radius = length(delta) * 2.0 * radialScale;
    float angle = atan2(delta.x, delta.y) * rcp(6.28) * lengthScale; // rcp(6.28) = 1.0 / 6.28
    return float2(radius, angle);
}

// 繰り返す
float2 repeat(float2 p, float n)
{
    return abs(fmod(p, n)) - n * 0.5;
}

// 繰り返す
float3 repeat(float3 p, float n)
{
    return abs(fmod(p, n)) - n * 0.5;
}

// 量子化する
// valueをstepの数で分割する
float Quantize(float value, float step)
{
    step = max(step, 0.0001);
    return floor(value * step) / step;
}

// UV座標をピクセル化する
// stepは分割数
float2 Pixelate(float2 uv, float step)
{
    uv.x = Quantize(uv.x, step);
    uv.y = Quantize(uv.y, step);

    return uv;
}

#endif

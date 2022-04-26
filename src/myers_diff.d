module myers_diff;


import std.stdio;
import std.typecons;
import std.math;
import std.array;
import std.conv;
template MyersDiff(T)
{
private:
    class V
    {
    private:
        long[] i_;
        long start_;
        long end_;
    public:
        this(long start, long end)
        {
            i_.length = end - start + 1;
            start_ = start;
            end_ = end;
        }
        long* at(long idx)
        {
            return &i_[idx - start_];
        }
    };
private:
    Tuple!(long, long, long, long, long) FindMiddleSnake(T[] a, T[] b)
    {
        long N = a.length;
        long M = b.length;
        long delta = N - M;
        long MAX = (M + N) * 2;
        auto fv = new V(-MAX, MAX);
        auto rv = new V(-MAX, MAX);
        long x, y;
        (*fv.at(1)) = 0;
        (*rv.at(delta + 1)) = N + 1;
        for (long D = 0; D <= ceil((M + N) / 2.0); D++) 
        {
            for (long k = -D; k <= D; k += 2) 
            {
                if (k == -D || (k != D && (*fv.at(k - 1)) < (*fv.at(k + 1)))) 
                {
                    x = (*fv.at(k + 1));
                } 
                else 
                {
                    x = (*fv.at(k - 1)) + 1;
                }
                y = x - k;
                while (x < N && y < M && a[x] == b[y]) 
                {
                    ++x;
                    ++y;
                }
                (*fv.at(k)) = x;
                if (delta % 2 != 0 && k >= delta - (D - 1) && k <= delta + D - 1) 
                {
                    if ((*fv.at(k)) >= (*rv.at(k))) 
                    {
                        return tuple((*rv.at(k)), (*rv.at(k)) - k, x, y, 2 * D - 1);
                    }
                }
            }

            for (long k = -D + delta; k <= D + delta; k += 2) 
            {
                if (k == -D + delta || (k != D + delta && (*rv.at(k - 1)) >= (*rv.at(k + 1)))) 
                {
                    x = (*rv.at(k + 1)) - 1;
                } 
                else 
                {
                    x = (*rv.at(k - 1));
                }
                y = x - k;
                while (x > 0 && y > 0 && a[x - 1] == b[y - 1]) 
                {
                    x -= 1;
                    y -= 1;
                }
                (*rv.at(k)) = x;
                if (delta % 2 == 0 && k >= -D && k <= D) 
                {
                    if ((*fv.at(k)) >= (*rv.at(k))) 
                    {
                        return tuple(x, y, (*fv.at(k)), (*fv.at(k)) - k, 2 * D);
                    }
                }
            }
        }
        return tuple(long(0), long(0), long(0), long(0), long(0));
    }
public:
    enum EditType 
    {
        Add = 0,
        Remove = 1
    };
    struct DiffResult 
    {
        long pos;
        EditType type;
        T str;
    };
    DiffResult[] getDiff(T[] a, T[] b, long offset = 0)
    {
        DiffResult[] rt;
        long N = a.length;
        long M = b.length;
        long Min = N < M ? N : M;
        long j = 0;
        for (;j < Min && a[0] == b[0]; ++j) 
        {
            a = a[1..$];
            b = b[1..$];
            --N;
            --M;
        }
        offset += j;
        while (N > 0 && M > 0 && a[N - 1] == b[M - 1]) 
        {
            --N;
            --M;
        }
        if (N > 0 && M > 0) 
        {
            auto t = FindMiddleSnake(a, b);
            rt ~= getDiff(a[0..t[0]], b[0..t[1]], offset);
            rt ~= getDiff(a[t[2]..$], b[t[3]..$], offset + t[2]);
        } 
        else if (N > 0) 
        {
            for (long i = 0; i < N; i++) 
            {
                DiffResult itm;
                itm.pos = i + offset;
                itm.type = EditType.Remove;
                itm.str = a[i];
                rt ~= itm;
            }
        } 
        else if (M > 0) 
        {
            for (long i = 0; i < M; i++) 
            {
                DiffResult itm;
                itm.pos = N + offset;
                itm.type = EditType.Add;
                itm.str = b[i];
                rt ~= itm;
            }
        }
        return rt;
    }
private:
    string formatOne(DiffResult r, string format, string strAdd, string strDelete)
    {
        string op = strAdd;
        if (r.type == EditType.Remove)
        {
            op = strDelete;
        }
        string pos = to!string(r.pos);
        string contest = to!string(r.str);
        return format.replace("%pos%", pos).replace("%type%", op).replace("%content%", contest);
    }
public:
    string formatResult(DiffResult[] results, string format, string strAdd, string strDelete)
    {
        string rt;
        foreach (ref r; results) 
        {
            rt ~= formatOne(r, format, strAdd, strDelete);
        }
        return rt;
    }
};

auto strDiff(string a, string b)
{
    alias strDiff =  MyersDiff!char;
    return strDiff.getDiff(a.dup, b.dup);
}

auto strDiffFormat(MyersDiff!(char).DiffResult[]  result, string format, string strAdd, string strDelet)
{
    alias strDiff = MyersDiff!char;
    return strDiff.formatResult(result, format, strAdd, strDelet);
}

auto lineDiff(string a, string b)
{
    alias lineDiff = MyersDiff!string;
    auto array_a = a.replace("\r", "").split("\n");
    auto array_b = b.replace("\r", "").split("\n");
    return lineDiff.getDiff(array_a, array_b);
}

auto lineDiffFormat(MyersDiff!(string).DiffResult[] result, string format, string strAdd, string strDelet)
{
    alias lineDiff = MyersDiff!string;
    return lineDiff.formatResult(result, format, strAdd, strDelet);
}


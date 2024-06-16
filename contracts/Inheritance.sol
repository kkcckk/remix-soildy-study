// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// 父类
contract Yeye {
    event Log(string msg);

    // 加上了virtual关键字，说明希望子类重写这个函数
    function hip() public virtual {
        emit Log("Yeye");
    }

    function pop() public virtual {
        emit Log("Yeye");
    }

    function yeye() public virtual {
        emit Log("Yeye");
    }
}


// 爷爷的子类，Baba类
contract Baba is Yeye{
    // 重写父类的函数
    // 重写的函数加上了关键字override
    function hip() public virtual override {
        emit Log("Baba");
    }

    function pop() public virtual override {
        emit Log("Baba");
    }

    // 自己独有的函数
    function baba() public virtual {
        emit Log("baba");
    }
}


// 爸爸的子类，Erzi类
contract Erzi is Yeye, Baba{
    // 重写父类和爷爷类同时存在的同名函数，需要加上爷爷类和父类
    function hip() public virtual override(Yeye, Baba) {
        emit Log("erzi");
    }

    function pop() public virtual override(Yeye, Baba) {
        emit Log("erzi");
    }

    function callParent() public {
        // 父类.父类的函数
        // 调用父类的函数
        Baba.pop();
    }

    function callParentSuper() public {
        Yeye.pop();
    }
}
# -*- coding: utf-8 -*-
"""
Created on Wed Apr 23 18:48:59 2025

@author: 13750
"""

from django.shortcuts import render, redirect,HttpResponse
import pymysql


def books(request):
    conn = pymysql.connect(host='127.0.0.1', port=3306, user='root', passwd='eric0613',
                           db='图书管理系统',charset='utf8')
    # 创建游标
    cursor = conn.cursor(cursor=pymysql.cursors.DictCursor)

    # 执行SQL，并返回收影响行数
    effect_row = cursor.execute("select 书名,位置,书号,价格 from books")
    book_list =cursor.fetchall()
    print(book_list)

    # 关闭游标
    cursor.close()
    # 关闭连接
    conn.close()
    # 将查询得到的数据放在class_list列表中
    return render(request,'books.html',{'book_list':book_list})



def select_book(request):
    if request.method == 'GET':
        return render(request,'select_book.html')
    else:
        # 获取html中的输入值
        v= request.POST.get('title')
        # 创建连接
        conn = pymysql.connect(host='127.0.0.1', port=3306, user='root', passwd='eric0613',
                               db='图书管理系统', charset='utf8')
        # 创建游标
        cursor = conn.cursor(cursor=pymysql.cursors.DictCursor)

        # 执行SQL
        #cursor.execute("insert into class(title) values(%s)", [v,])
        cursor.execute("select * from books where 书名= %s",v)
        book_list =cursor.fetchall()
        print(book_list)
        
        conn.commit()

        # 关闭游标
        cursor.close()
        # 关闭连接
        conn.close()

        # 重新定向到url_patterns总
        return render(request,'select_book.html',{'book_list':book_list})












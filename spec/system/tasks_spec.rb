require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { create(:user) }
  let(:task) { create(:task) }

  describe 'ログイン前' do
    describe 'ページ遷移確認' do
      context 'タスクの新規登録ページにアクセス' do
        it '新規登録ページへのアクセスが失敗する' do
          visit new_task_path
          expect(page).to have_content "Login required"
          expect(current_path).to eq login_path
        end
      end

      context 'タスクの編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
          visit edit_task_path(user)
          expect(page).to have_content "Login required"
          expect(current_path).to eq login_path
        end
      end

      context 'タスクの詳細ページにアクセス' do
        it 'タスクの詳細情報が表示される' do
          visit task_path(task)
          expect(page).to have_content task.title
          expect(page).to have_content task.status
          expect(current_path).to eq task_path(task)
        end
      end

      context 'タスクの一覧ページにアクセス' do
        it 'すべてのユーザーのタスク情報が表示される' do
          tasks = create_list(:task, 3)
          visit tasks_path
          expect(page).to have_content tasks[0].title
          expect(page).to have_content tasks[1].title
          expect(page).to have_content tasks[2].title
          expect(current_path).to eq tasks_path
        end
      end
    end
  end

  describe 'ログイン後' do
    before { sign_in_as(user) }

    describe 'タスク新規登録' do
      context 'フォームの入力値が正常' do
        it 'タスクの新規作成が成功する' do
          visit new_task_path
          fill_in "Title", with: "Test Title"
          fill_in "Content", with: "Test content"
          select "doing", from: "Status"
          fill_in "Deadline", with: DateTime.new(2020, 11, 30, 10, 9)
          click_button "Create Task"
          expect(page).to have_content "Task was successfully created."
          expect(page).to have_content "Test Title"
          expect(page).to have_content "Test content"
          expect(page).to have_content "doing"
          expect(page).to have_content "2020/11/30 10:9"
          expect(current_path).to eq task_path(1)
        end
      end

      context 'タイトルが未入力' do
        it 'タスクの新規作成が失敗する' do
          visit new_task_path
          fill_in "Title", with: ""
          fill_in "Content", with: "Test content"
          select "doing", from: "Status"
          fill_in "Deadline", with: DateTime.new(2020, 11, 30, 10, 9)
          click_button "Create Task"
          expect(page).to have_content "1 error prohibited this task from being saved"
          expect(page).to have_content "Title can't be blank"
          expect(current_path).to eq tasks_path
        end
      end

      context '登録済のタイトルを入力' do
        it 'タスクの新規作成が失敗する' do
          create(:task, title: "Test title")
          visit new_task_path
          fill_in "Title", with: "Test title"
          fill_in "Content", with: "Test content"
          select "doing", from: "Status"
          fill_in "Deadline", with: DateTime.new(2020, 11, 30, 10, 9)
          click_button "Create Task"
          expect(page).to have_content "1 error prohibited this task from being saved"
          expect(page).to have_content "Title has already been taken"
          expect(current_path).to eq tasks_path
        end
      end
    end

    describe 'タスク編集' do
      let!(:task) { create(:task, user: user) }
      before { visit edit_task_path(task) }

      context 'フォームの入力値が正常' do
        it 'タスクの編集が成功する' do
          fill_in "Title", with: "Update Test Title"
          fill_in "Content", with: "Update Test content"
          select "doing", from: "Status"
          click_button "Update Task"
          expect(page).to have_content "Task was successfully updated."
          expect(page).to have_content "Update Test Title"
          expect(page).to have_content "Update Test content"
          expect(page).to have_content "doing"
          expect(current_path).to eq task_path(task)
        end
      end

      context 'タイトルが未入力' do
        it 'タスクの編集が失敗する' do
          fill_in "Title", with: ""
          click_button "Update Task"
          expect(page).to have_content "1 error prohibited this task from being saved"
          expect(page).to have_content "Title can't be blank"
          expect(current_path).to eq task_path(task)
        end
      end

      context '登録済のタイトルを入力' do
        it 'タスクの編集が失敗する' do
          create(:task, title: "Same Title")
          fill_in "Title", with: "Same Title"
          click_button "Update Task"
          expect(page).to have_content "1 error prohibited this task from being saved"
          expect(page).to have_content "Title has already been taken"
          expect(current_path).to eq task_path(task)
        end
      end
    end

    describe 'タスク削除' do
      let!(:task) { create(:task, user: user) }

      it 'タスクの削除が成功する' do
        visit tasks_path
        click_link "Destroy"
        expect(page.accept_confirm).to eq 'Are you sure?'
        expect(page).to have_content "Task was successfully destroyed."
        expect(current_path).to eq tasks_path
        expect(page).to_not have_content task.title
      end
    end
  end
end
